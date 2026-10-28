<template>
    <v-card :to="`/game/${gameId}`" color="secondary" class="myFont">
        <v-card-title class="pa-0">
            <v-toolbar color="secondary" density="compact" class="ma-0">
                <v-toolbar-title class="text-h6 ma-0">
                    {{ gameId }}
                </v-toolbar-title>
                <v-btn style="position: absolute; right: 0;" icon="mdi-delete-forever-outline" variant="text"
                       density="compact" color="grey-darken-2" @click.prevent="openDeleteDialog"></v-btn>
                <v-btn style="position: absolute; right: 50px;" variant="text"
                       density="compact" color="primary" @click.prevent="toggleGameState">{{ gameStateText }}</v-btn>
            </v-toolbar>
        </v-card-title>
        <v-card-text v-if="gameState && gameState.teams">
            <div :class="`text-${gameState.teams[teamBlueId]?.color || 'blue'}-darken-1`">{{ gameState.teams[teamBlueId]?.name }}</div>
            <div :class="`text-${gameState.teams[teamRedId]?.color || 'red'}-darken-1`">{{ gameState.teams[teamRedId]?.name }}</div>
        </v-card-text>
    </v-card>

    <v-snackbar
            v-model="snackbar"
            timeout="2500"
            :color="snackbarColor">
        {{ snackbarText }}
    </v-snackbar>

    <v-dialog v-model="deleteDialog" max-width="500">
        <v-card>
            <v-card-title class="headline">Confirm Deletion</v-card-title>
            <v-card-text>Are you sure you want to delete the game?</v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn color="grey" text @click="deleteDialog = false">Cancel</v-btn>
                <v-btn color="red" text @click="confirmDelete">Delete</v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>

<script setup>
import {useFetch, useRuntimeConfig} from "#app";
import {useAuthStore} from "~/stores/auth";
import {getSideTeamIds} from "~/utils/teams";

const {$promptPassword} = useNuxtApp()

const baseApiUrl = useRuntimeConfig().public.baseApiUrl
const auth = useAuthStore()
const props = defineProps(['gameId'])
const emit = defineEmits(['gameDeleted'])

const snackbar = ref(false)
const snackbarText = ref("")
const snackbarColor = ref("")
const deleteDialog = ref(false)

const gameState = ref(null)
const teamBlueId = ref(null)
const teamRedId = ref(null)
const gameStateText = ref("")

const fetchGameState = async (retries = 5, delay = 1000) => {
    for (let attempt = 1; attempt <= retries; attempt++) {
        const {data, error} = await useFetch(baseApiUrl + `/game/${props.gameId}`, {
            method: 'GET',
            pick: ["teams", "game_on"]
        })

        if (error.value) {
            console.error("Error fetching game state:", error.value)
            snackbar.value = true
            snackbarText.value = "Failed to fetch game state"
            snackbarColor.value = "error"
            return
        }

        gameState.value = data.value

        if (gameState.value) {
            if (gameState.value.teams) {
                [teamBlueId.value, teamRedId.value] = getSideTeamIds(gameState.value.teams)
            }
            gameStateText.value = gameState.value.game_on ? "STOP" : "START"
            return
        }

        // Wait before retrying
        await new Promise(resolve => setTimeout(resolve, delay))
    }

    console.error("Failed to fetch game state after multiple attempts")
    snackbar.value = true
    snackbarText.value = "Failed to fetch game state after multiple attempts"
    snackbarColor.value = "error"
}

const openDeleteDialog = () => {
    deleteDialog.value = true
}

const confirmDelete = async () => {
    deleteDialog.value = false
    const {data, error} = await useFetch(baseApiUrl + `/game/`, {
        method: 'delete',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Basic ' + btoa(`${props.gameId}:${auth.getPass(props.gameId)}`)
        },
    })

    if (error.value) {
        const errorMessage = error.value.message || error.value.toString()
        const statusMatch = errorMessage.match(/: (\d{3}) /)
        const status = statusMatch ? parseInt(statusMatch[1], 10) : null
        if (status === 401) {
            $promptPassword(props.gameId)
        } else {
            snackbar.value = true
            snackbarText.value = error.value
            snackbarColor.value = "error"
        }
        return
    }

    if (data.value) {
        snackbar.value = true
        snackbarText.value = "Game deleted successfully"
        snackbarColor.value = ""
        emit('gameDeleted')
    }
}

const toggleGameState = async () => {
    const urlText = gameState.value.game_on ? "stop" : "start"

    const {error} = await useFetch(baseApiUrl + `/game/${urlText}`, {
        method: 'put',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Basic ' + btoa(`${props.gameId}:${auth.getPass(props.gameId)}`)
        },
    });

    if (error.value) {
        const errorMessage = error.value.message || error.value.toString()
        const statusMatch = errorMessage.match(/: (\d{3}) /)
        const status = statusMatch ? parseInt(statusMatch[1], 10) : null
        if (status === 401) {
            $promptPassword(props.gameId)
        } else {
            snackbar.value = true
            snackbarText.value = `Error ${gameState.value.game_on ? 'stopping' : 'starting'} the game`
            snackbarColor.value = "error"
        }
    } else {
        gameState.value.game_on = !gameState.value.game_on
        gameStateText.value = gameState.value.game_on ? "STOP" : "START"
        snackbar.value = true
        snackbarText.value = `Game ${gameState.value.game_on ? 'started' : 'stopped'} successfully`
        snackbarColor.value = "success"
        fetchGameState()
    }
}

onMounted(() => {
    fetchGameState()
})

watch(() => props.gameId, () => {
    fetchGameState()
})
</script>

<style scoped>
</style>