from renpybuild.context import Context
from renpybuild.task import task

version = "3.3.2"


@task()
def unpack(c: Context):
    c.clean()

    c.var("version", version)
    c.run("tar xzf {{source}}/openssl-{{version}}.tar.gz")


@task()
def build(c: Context):
    c.var("version", version)
    c.chdir("openssl-{{version}}")

    if c.platform == "mac":
        c.env("KERNEL_BITS", "64")

    if (c.platform == "windows") and (c.arch == "x86_64"):
        # c.env("CFLAGS", "{{ CFLAGS }} -DNOCRYPT")
        c.run("""./Configure mingw64 no-shared no-asm no-engine no-apps threads --prefix="{{ install }}" """)
    elif c.platform == "android":
        c.run("""./Configure cc no-shared no-asm no-engine no-apps threads --prefix="{{ install }}" """)
    elif c.platform == "web":
        raise Exception("OpenSSL isn't configured to be build for web")
    elif c.platform == "ios":
        if c.arch in ["sim-x86_64", "sim-arm64"]:
            # iOS Simulator
            c.run("""./Configure iossimulator-xcrun no-shared no-asm no-engine no-apps threads --prefix="{{ install }}" """)
        else:
            # iOS Device (arm64, armv7s)
            c.run("""./Configure ios64-xcrun no-shared no-asm no-engine no-apps threads --prefix="{{ install }}" """)
    else:
        c.run("""./Configure cc no-shared no-asm no-engine no-apps threads -lpthread --prefix="{{ install }}" """)

    # OpenSSL 3.x sometimes requires running make twice due to dependency generation
    try:
        c.run("""{{ make }}""")
    except:
        # If first make fails with "Please run the same make command again", try again
        print("First make failed, trying again as requested by OpenSSL...")
        c.run("""{{ make }}""")

    c.run("""make install_sw""")
