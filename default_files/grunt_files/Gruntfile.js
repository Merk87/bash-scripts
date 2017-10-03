module.exports = function (grunt) {
    grunt.initConfig({
        cssmin: {
            dev: {
                options: {
                    sourceMap: true
                },
                files: {
                    'css/combined-styles.min.css': [
                        'Sources/Css/.css',
                    ]
                }
            },
            production: {
                files: {
                    'css/combined-styles.min.css': [
                        'Sources/Css/.css',
                    ]
                }
            }
        },
        uglify: {
            dev: {
                options: {
                    sourceMap: true,
                    sourceMapName: 'js/scripts.map',
                    beautify: true,
                    compress: false,
                    mangle: false
                },
                files: {
                    'js/global.min.js': [
                        'Sources/Js/.js'
                    ]
                }
            },
            production: {
                options: {
                    sourceMap: false,
                    compress: {
                        drop_console: true
                    }
                },
                files: {
                    'js/global.min.js': [
                        'Sources/Js/.js'
                    ]
                }
            }
        },
        /**
         * watch
         */
        watch: {
            scripts: {
                files: ['Sources/Js/*.js', 'Sources/Css/*.css'],
                tasks: ['cssmin:dev', 'uglify:dev'],
                options: {}
            }
        }

    });
    grunt.loadNpmTasks('grunt-contrib-cssmin');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-watch');

    // Default task(s).
    grunt.registerTask('default', ['cssmin:production', 'uglify:production']);
    grunt.registerTask('dev', ['cssmin:dev', 'uglify:dev']);
};
