/*global JSHINT, readline, print, quit */
"use strict";

function main(argv) {
    var path = argv[0];
    
    // Slurp stdin into input; assumes all lines are prefixed with some char
    // that we strip away. We do this because readline() returns undef on a
    // blank line.
    var input = '';
    var line = '';
    while ((line = readline())) {
        input += line.substring(1) + "\n";
    }
    
    // Use some very strict defaults. Each of these can be overridden on a per-
    // file basis using a /*jshint foo:true */ comment.

    var options = {
        // ENFORCING
    bitwise: true, // prohibits the use of bitwise operators
    curly: true, // requires curly braces around loops and conditionals
    eqeqeq: true, // prohibits == and != in favor of === and !==
    forin: true, // requires `for in` loops to filter objects' items
    immed: true, // requires immediate functions to be wrapped in parens
    latedef: true, // prohibit use of variable before it is defined
    newcap: true, // requires constructor functions to begin with a capital
    noarg: true, // prohibits use of arguments.caller and arguments.callee
    noempty: true, // warn if an empty block appears in your code
    nonew: true, // prohibit use of constructors for side-effects
    plusplus: true, // prohibit use of ++ and --
    regexp: true, // prohibit use of unsafe . in regular expressions
    undef: true, // prohibit use of explicitly undeclared variables
    strict: true, // requires EcmaScript 5's strict mode
    trailing: true, // warn about trailing whitespace
        // RELAXING
    asi: false, // don't warn about missing semicolons
    boss: false, // don't warn about assignments where comparisons expected
    debug: false, // don't warn about debugger statements
    eqnull: false, // don't warn about == null comparisons
    es5: false, // don't warn about EcmaScript 5 specific features
    evil: false, // don't warn about eval()
    expr: false, // don't warn about expressions where assignment expected
    globalstrict: false, // don't warn about global strict mode
    iterator: false, // don't warn about __iterator__ property
    lastsemic: false, // don't warn about missing semicolons for last statement in a one-liner
    laxbreak: false, // don't warn about unsafe line breaks
    loopfunc: false, // don't warn about functions inside of loops
    onecase: false, // don't warn about switches with just one case
    proto: false, // don't warn about the __proto__ property
    regexdash: false, // don't warn about unescaped - in regular expressions
    scripturl: false, // don't warn about javascript: URLs
    shadow: false, // don't warn about variable shadowing
    sub: false, // don't warn about using [] notation where . notation works
    supernew: false, // don't warn about weird constructors
    validthis: false // don't warn about using this outside of a constructor
    };
    
    if (!JSHINT(input, options)) {
        for (var i = 0; i < JSHINT.errors.length; i += 1) {
            var e = JSHINT.errors[i];
            if (e) {
                print(path + ':' + e.line + ': warning: ' + e.reason);
                /* print((e.evidence || '').replace(/^\s*(\S*(\s+\S+)*)\s*$/, "$1")); */
            }
        }
        quit(2);
    } else {
        print('No problems found in ' + path);
        quit(0);
    }
}

main(arguments);
