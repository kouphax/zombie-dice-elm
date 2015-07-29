module.exports = function(grunt) {

  grunt.initConfig({
    elm: {
      compile: {
        files: {
          "zombiedice.js": ["ZombieDice.elm"]
        }
      }
    },
    sass: {
        dist: {
            files: {
                'css/styles.css': 'sass/styles.scss',
                'css/gridpak.css': 'sass/gridpak.scss'
            }
        }
    },
    watch: {
      elm: {
        files: ["Confirm.elm"],
        tasks: ["elm"]
      },
      sass: {
        files: ['sass/styles.scss', 'sass/gridpak.scss'],
        tasks: ['sass']
      }
    },
    clean: ["elm-stuff/build-artifacts", "css/gridpak.scss", "css/styles.css"]
  });

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-elm');
  grunt.loadNpmTasks('grunt-sass');

  grunt.registerTask('default', ['elm', 'sass']);

};
