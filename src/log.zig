const std = @import("std");

pub const Ansi = struct {
    pub const reset = "\x1b[0m";
    pub const green = "\x1b[32m";
    pub const yellow = "\x1b[33m";
    pub const red = "\x1b[31m";
    pub const cyan = "\x1b[36m";
    pub const bright_black = "\x1b[90m";
};

const LogLevel = enum {
    ok,
    warn,
    err,
    info,
    debug,
};

pub fn log(level: LogLevel, comptime fmt: []const u8, args: anytype) !void {
    const color = switch (level) {
        .ok => Ansi.green,
        .warn => Ansi.yellow,
        .err => Ansi.red,
        .info => Ansi.cyan,
        .debug => Ansi.bright_black,
    };

    const label = switch (level) {
        .ok => "[OK]",
        .warn => "[WARN]",
        .err => "[ERROR]",
        .info => "[INFO]",
        .debug => "[DEBUG]",
    };

    std.debug.print("{s}{s}{s} ", .{ color, label, Ansi.reset });
    std.debug.print(fmt ++ "\n", args);
}
