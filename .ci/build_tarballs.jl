# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

# Collection of sources required to build LCIOWrapBuilder
sources = [
    "https://github.com/jstrube/LCIOWrapBuilder.git" =>
    "451f42e9b3daf41156db502ee45ee8884b77efd2",
]

# Bash recipe for building across all platforms
function getscript(version)
	shortversion = version[1:3]
	return """
	Julia_ROOT=/usr/local
	cd /usr/local
	curl -L "https://github.com/JuliaPackaging/JuliaBuilder/releases/download/$version/julia-$version-\$target.tar.gz" | tar -zx --strip-components=1
	cd \$WORKSPACE/srcdir
	mkdir build && cd build
	cmake -DCMAKE_INSTALL_PREFIX=\$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/\$target/\$target.toolchain -DJulia_ROOT=\$Julia_ROOT ../LCIOWrapBuilder/
	VERBOSE=ON cmake --build . --config Release --target install
	"""
end

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "liblciowrap", :l_lciowrap)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaInterop/libcxxwrap-julia/releases/download/v0.3.2/build_libcxxwrap-julia-1.0.v0.3.2.jl"
    "https://github.com/jstrube/LCIOBuilder/releases/download/v2.00.01/build_LCIOBuilder.v2.12.1.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
version_number = get(ENV, "TRAVIS_TAG", "")
if version_number == ""
    version_number = "v0.99"
end
build_tarballs(ARGS, "LCIOWrapBuilder", VersionNumber(version_number), sources, getscript("1.0.0"), platforms, products, dependencies)
