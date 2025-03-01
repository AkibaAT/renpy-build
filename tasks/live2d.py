from renpybuild.context import Context
from renpybuild.task import task, annotator


@annotator
def annotate(c: Context):
    c.include("{{ install }}/cubism/Core/include")
    c.env("CUBISM", "{{ install }}/cubism")


@task(platforms="all")
def build(c: Context):
    c.clean()

    # Find the Cubism SDK zip file dynamically
    import glob
    import os

    tars_path = c.path("{{ tars }}")
    cubism_pattern = "CubismSdkForNative-[45]-*.zip"
    cubism_files = glob.glob(str(tars_path / cubism_pattern))

    if not cubism_files:
        print(f"No Cubism SDK found matching pattern {cubism_pattern} in {tars_path}")
        return

    # Sort and use the latest version (lexicographically last)
    cubism_files.sort()
    cubism_zip_path = cubism_files[-1]
    cubism_zip = os.path.basename(cubism_zip_path)

    # Extract directory name from zip filename (remove .zip extension)
    cubism_dir = cubism_zip[:-4]

    c.var("cubism_zip", cubism_zip)
    c.var("cubism_dir", cubism_dir)
    c.var("live2d", c.path("{{ root }}/live2d"))

    print(f"Using Cubism SDK: {cubism_zip}")

    c.run("unzip -q {{ tars }}/{{ cubism_zip }}")

    c.rmtree("{{ install }}/cubism")
    c.run("mv {{cubism_dir}} {{ install }}/cubism")
