// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
    app: {
        head: {
            meta: [
                {name: "description", content: "User interface for FRI RoboLiga"}
            ],
            title: "RoboLiga",
        }
    },
    css: [
        "vuetify/styles",
        "@mdi/font/css/materialdesignicons.min.css"
    ],
    modules: [
        '@pinia/nuxt',
        'pinia-plugin-persistedstate/nuxt',
    ],
    runtimeConfig:{
        public: {
            baseApiUrl: 'http://192.168.1.44:8088',
            //baseApiUrl: 'http://localhost:8088',
        }
    },
    build: {
        transpile: ["vuetify"],
    },
    plugins: [
        "~/plugins/promptPassword",
    ],
})