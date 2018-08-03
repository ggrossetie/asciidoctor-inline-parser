const assert = require('assert');
const Opal = require('opal-runtime').Opal;
require('./build/asciidoctor-inline-parser');

const result = Opal.Asciidoctor.InlineParser.$parse('*bold*');
assert(result !== Opal.nil, 'The inline parser must be able to parser: *bold*');
