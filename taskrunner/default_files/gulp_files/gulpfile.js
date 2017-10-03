var gulp = require('gulp'),
    gutil = require('gulp-util');

var cachehyperbust = require('gulp-cache-hyper-bust');

var timestamp = new Date().getTime();

gulp.task('cache-hyper-bust', function(){

    gulp.src(['./**/*.php', '!./dev*/**/', '!./news/**/', '!./CodeLibrary/**/*.*'])
        .pipe(cachehyperbust({
            type: 'timestamp',
            images: false,
	    staticTimestamp: timestamp
        }))
        .pipe(gulp.dest('.'));
});


gulp.task('default', [ 'cache-hyper-bust']);
