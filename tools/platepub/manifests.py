"""Write the per-language publish manifests that the country repos do not have yet."""
import json
import re

from .areas import describe
from .registries import JSR_SCOPE, MAVEN_GROUP, REGISTRIES, dash
from .util import OWNER, ROOT, git

CORE_RANGE = "0.1.0"


def _meta(pkg):
    country, area = describe(pkg)
    pub = (ROOT / pkg / "flutter/pubspec.yaml").read_text()
    version = (re.search(r"^version:\s*(\S+)", pub, re.M) or [0, "0.1.0"])[1]
    rc, url = git(ROOT / pkg, "remote", "get-url", "origin")
    url = re.sub(r"\.git$", "", url) if rc == 0 and url else f"https://github.com/{OWNER}/{pkg}"
    what = f"{area}, {country}" if area else country
    return {"version": version, "url": url, "desc": f"Licence plates of {what}: specs, themes and validator for the plates library."}


def _entries(pkg):
    """{subpath: ts entry file} for each country folder under typescript/src/countries."""
    base = (pkg[:-6] if pkg.endswith("_plate") else pkg)
    root = ROOT / pkg / "typescript/src/countries"
    dirs = sorted(d.name for d in root.iterdir() if (d / "index.ts").exists()) if root.exists() else []
    out = {f"./{d}": f"./src/countries/{d}/index.ts" for d in dirs}
    if base in dirs or len(dirs) == 1:
        out = {".": f"./src/countries/{base if base in dirs else dirs[0]}/index.ts", **out}
    return out


def package_json(pkg, m):
    d = {"name": REGISTRIES["npm"].name(pkg), "version": m["version"], "description": m["desc"], "type": "module",
         "license": "MIT", "repository": {"type": "git", "url": f"git+{m['url']}.git", "directory": "typescript"},
         "exports": _entries(pkg), "files": ["src"], "publishConfig": {"access": "public"}}
    if pkg != "plate_core":
        d["dependencies"] = {"plate_core": f"^{CORE_RANGE}"}
    return json.dumps(d, indent=2) + "\n"


def jsr_json(pkg, m):
    d = {"name": REGISTRIES["jsr"].name(pkg), "version": m["version"], "license": "MIT", "exports": _entries(pkg),
         "publish": {"include": ["src/**/*.ts", "README.md"]}}
    return json.dumps(d, indent=2) + "\n"


def pyproject(pkg, m):
    dep = "" if pkg == "plate_core" else 'dependencies = ["plate_core>=0.1"]\n'
    return f'''[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.build_meta"

[project]
name = "{pkg}"
version = "{m["version"]}"
description = "{m["desc"]}"
readme = "README.md"
license = {{text = "MIT"}}
requires-python = ">=3.10"
{dep}
[project.urls]
Repository = "{m["url"]}"

[tool.setuptools.packages.find]
include = ["plates.countries.*"]
namespaces = true
'''


def gradle(pkg, m):
    art = pkg
    core = "" if pkg == "plate_core" else f'            api("{MAVEN_GROUP}:plate_core:{CORE_RANGE}")\n'
    return f'''plugins {{
    kotlin("multiplatform") version "2.2.20"
    id("com.vanniktech.maven.publish") version "0.34.0"
}}

group = "{MAVEN_GROUP}"
version = "{m["version"]}"

kotlin {{
    jvmToolchain(21)
    jvm()
    js(IR) {{ browser() }}
    sourceSets {{
        commonMain.dependencies {{
{core}        }}
    }}
}}

mavenPublishing {{
    publishToMavenCentral(automaticRelease = true)
    if (providers.gradleProperty("signingInMemoryKey").isPresent || providers.gradleProperty("signing.keyId").isPresent) signAllPublications()  // dry runs have no key
    coordinates("{MAVEN_GROUP}", "{art}", "{m["version"]}")
    pom {{
        name.set("{art}")
        description.set("{m["desc"]}")
        url.set("{m["url"]}")
        licenses {{ license {{ name.set("MIT License"); url.set("https://opensource.org/licenses/MIT") }} }}
        developers {{ developer {{ id.set("{OWNER.lower()}"); name.set("ArAd Beyranvand") }} }}
        scm {{ url.set("{m["url"]}"); connection.set("scm:git:{m["url"]}.git") }}
    }}
}}
'''


def settings(pkg, m):
    return f'rootProject.name = "{pkg}"\n'


# registry -> [(file, builder)]
FILES = {"npm": [("package.json", package_json)], "jsr": [("jsr.json", jsr_json)],
         "pypi": [("pyproject.toml", pyproject)],
         "maven": [("build.gradle.kts", gradle), ("settings.gradle.kts", settings)]}


def init(pkg, regs, log, force=False):
    """Write missing manifests (never overwrites without `force`); returns the files written."""
    m, written = _meta(pkg), []
    for key in regs:
        reg = REGISTRIES[key]
        for fname, build in FILES.get(key, []):
            f = reg.dir(pkg) / fname
            if not reg.dir(pkg).exists():
                log(f"{pkg}: no {reg.subdir}/ folder, skipped {key}")
                break
            if f.exists() and not force:
                continue
            f.write_text(build(pkg, m))
            written.append(f.relative_to(ROOT))
    return written
