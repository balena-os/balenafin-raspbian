# balenaFin Raspbian support packages and tools

This repository includes metadata and tools for generating and maintaining [balenaFin](https://balenafin.io) specific Debian packages.
The Debian repository is available on [bintray](https://bintray.com) at [balenaos/raspbian](https://bintray.com/balenaos/raspbian).

## Debian packages generation

The packages supported are structured as subdirectories in `debs`. In order to generate Debian artefacts for one of these packages run `gen-deb-container.sh` with appropriate arguments (see tool's help for more info). This will generate the artefacts in the respective package's directory.

For example, running `./gen-deb-container.sh --package FOO`, will generate the deb package (and additional artefacts) in `debs/FOO/`.

## Upload to bintray

In order to upload a deb file to `bintray` use `upload-to-bintray.sh`. This requires an API key passed to the tool.

## Upgrading a package

Each package, structured as a subdirectory in `debs`, has the following content:

    .
    ├── deb-root		# This is the workspace of the debian package generator.
    │   └── debian		# Debian package metadata. See [debian manual](https://www.debian.org/doc/manuals/maint-guide/dreq.en.html) for more info.
    └── src			# Package's source directory - usually a git submodule.

In order to upgrade a package

* Update the `src` git submodule to the new version (if required).
* Add changelog entry for the new version (if `src` was updated, specify the new package version and reset the revision to 1 or increment the revision if only files in `debian` directory were modified).
  * For example: Current version is 1.0.0-3 and updated `src` from 1.0.0 to 2.0.0 -> Add changelog entry for 2.0.0-1.
  * For example: Current version is 2.0.0-2 and changed the `rules` files in `debian` directory -> Add a changelog entry for 2.0.0-3
* The changelog is parsed for the package's version so be careful when adding changelog entries. See [debian manual:changelog](https://www.debian.org/doc/manuals/maint-guide/dreq.en.html#changelog) for more info.
* Regenerate the deb as per above instructions.
* Upload the new deb as per above instructions.

## License

Copyright 2019 Rulemotion Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
