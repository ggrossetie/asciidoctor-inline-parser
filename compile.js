'use strict';
const fs = require('fs');
const bfs = require('bestikk-fs');
const download = require('bestikk-download');
const OpalBuilder = require('opal-compiler').Builder;

const getContentFromURL = (url, target) => {
  return new Promise(resolve => {
    download.getContentFromURL(url, target, () => resolve({target}))
  })
};

const untar = (source, baseDirName, destinationDir) => {
  return new Promise(resolve => {
    bfs.untar(source, baseDirName, destinationDir, () => resolve({}));
  })
};

const replaceUnsupportedRegexp = (target) => {
  let data = fs.readFileSync(target, 'utf8');
  // replace dot wildcard with negated line feed in single-line match expressions
  data = data.replace(/"\\\\A/g, '"^');
  fs.writeFileSync(target, data, 'utf8');
};

(async function () {
  const treetopVersion = '725eb7f9e5e80105f3b39424b40ad014addd9035'; // 1.6.10 (no tag available)
  const target = 'build/treetop.tar.gz';
  bfs.removeSync('build');
  bfs.mkdirsSync('build');
  if (!fs.existsSync(target)) {
    await getContentFromURL(`https://codeload.github.com/cjheath/treetop/tar.gz/${treetopVersion}`, target);
    await untar(target, 'treetop', 'build');
  }
  const opalBuilder = OpalBuilder.create();
  opalBuilder.appendPaths('build/treetop/lib');
  opalBuilder.appendPaths('node_modules/opal-compiler/src/stdlib');
  opalBuilder.appendPaths('lib');
  opalBuilder.setCompilerOptions({dynamic_require_severity: 'ignore'});
  fs.writeFileSync('build/asciidoctor-inline-parser.js', opalBuilder.build('asciidoctor/inline_parser').toString(), 'utf8');
  replaceUnsupportedRegexp('build/asciidoctor-inline-parser.js');
})().catch(error => {
  console.log(error);
});
