const std = @import("std");
const log = @import("log.zig");
pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);

    if (args.len < 3 or !std.mem.eql(u8, args[1], "add")) {
        try log.log(.info, "Usage: zpm add <git-url>\n", .{});
        return;
    }

    const git_url = args[2];
    const id = try getOwnerAndRepo(git_url);

    const dest_path = try std.fs.path.join(allocator, &[_][]const u8{
        "zpm", id.owner, id.repo,
    });

    const cwd = std.fs.cwd();
    if (cwd.openDir(dest_path, .{}) catch null != null) {
        try log.log(.info, "Package already exists at {s}", .{dest_path});
        return;
    }

    const parent = std.fs.path.dirname(dest_path) orelse return error.InvalidPath;
    try cwd.makePath(parent);

    try cloneGitRepo(allocator, git_url, dest_path);

    try log.log(.info, "Package cloned to {s}", .{dest_path});
}

const RepoID = struct {
    owner: []const u8,
    repo: []const u8,
};

fn getOwnerAndRepo(url: []const u8) !RepoID {
    var parts = std.mem.splitAny(u8, url, "/:");

    var segments: [16][]const u8 = undefined;
    var count: usize = 0;

    while (parts.next()) |part| {
        if (part.len > 0) {
            if (count >= segments.len) {
                try log.log(.err, "Too many segments for repo ID parsing", .{});
                return error.InvalidRepoURL;
            }
            segments[count] = part;
            count += 1;
        }
    }

    if (count < 2) return error.InvalidRepoURL;

    const owner = segments[count - 2];
    var repo = segments[count - 1];

    if (std.mem.endsWith(u8, repo, ".git")) {
        repo = repo[0 .. repo.len - 4];
    }

    return RepoID{ .owner = owner, .repo = repo };
}

pub fn cloneGitRepo(allocator: std.mem.Allocator, git_url: []const u8, dest_path: []const u8) !void {
    const argv = &[_][]const u8{ "git", "clone", git_url, dest_path };

    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = argv,
    });

    if (result.term.Exited != 0) {
        try log.log(.err, "Git clone failed with exit code {}", .{result.term.Exited});
        return error.GitCloneFailed;
    }

    try log.log(.info, "Package cloned to {s}", .{dest_path});
}
