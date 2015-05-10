# Github-Star
A chrome extension to get information from stars in Github.

## Building

In the repo's base path simply run:

```sh
$ npm run release
```

This will compile and compress the required CoffeeScript and CSS files under `./source` to the `./release` directory.

You must have npm (node.js's package manager) installed, which can be found in http://nodejs.org/

## Contributing

Contributors must **privately** fork the repo, make changes and then issue a Pull Request. Then, the Pull Request will be merged with the `qa` branch, tested and, if succesfull, merged into `master`.

It's very important that each Pull Request has an issue associated to (so it can be discussed) and that issue should contain info on what the change is about.

The recommended contributing workflow is:

1. Developer forks project **privately**.
2. Developer creates an issue with a new feature or bug. Remember that *good issues* are as atomic as possible (1 feature/bug per issue). Change is proposed in the issue and request comments if neccesary.
3. Developer codes, eats pizza and drinks coffee, then creates a new Pull Request referencing the issue.
4. PR is merged into `qa`, tested and then merged into `master`.
5. ScreenPlayer's version is bumped

#### Versioning
The recommended versioning schema (start at version 1.0.0) is [SemVer](http://semver.org/). tl;dr: &lt;major&gt;.&lt;minor&gt;.&lt;patch&gt;

## Ownership

Please remember this is a **private** project.

> :heart: @ivolivares