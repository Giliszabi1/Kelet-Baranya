const {select} = require('@inquirer/prompts');

async function mainMenu(params) {
    while (true) {
        console.clear()

        const action = await select({
            message: "Server console",
            choices: [
                {
                    name: "Create admin",
                    value: "adminCreate"
                },
                {
                    name: "Exit",
                    value: "exit"
                }
            ]
        })
        switch (action) {
            case 'adminCreate':
                break;
            case 'exit':
                break;
            default:
                break;
        }
    }
}

module.exports = mainMenu;