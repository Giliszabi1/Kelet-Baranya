const mainMenu = require('./menu');

async function start() {
    console.clear()

    console.log("------------------------------")
    console.log("        Application CLI")
    console.log("------------------------------")

    try {
        await mainMenu()
    } catch (error) {
        console.error(error)
    }
}
start()