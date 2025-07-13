# Maintainer: Tosterlolz <tosterlolz@proton.me>
pkgname=zpm
pkgver=0.1.0
pkgrel=1
pkgdesc="Zig Package Manager that supports git-based modules"
arch=('x86_64')
url="https://github.com/tosterlolz/zpm"
license=('MIT')
depends=('zig' 'git')
makedepends=('zig')
source=("$pkgname-$pkgver.tar.gz")
sha256sums=('SKIP') # Replace with actual checksum if needed
source=("git+file://$PWD")
sha256sums=('SKIP')

pkgver() {
  cd "$srcdir/$_gitname"
  echo "0.1.0"
}

build() {
  cd "$srcdir/zpm"
  zig build
}

package() {
  cd "$srcdir/zpm"
  install -Dm755 zig-out/bin/zpm "$pkgdir/usr/bin/zpm"
}