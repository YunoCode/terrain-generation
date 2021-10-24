const Http = require('http')
const fs = require('fs')
const path = require('path')
const Port = 3000

const delay = ms => new Promise(resolve => setTimeout(resolve, ms))

const express = require('express')
const bodyParser = require('body-parser')
const { dir } = require('console')

const app = express()
const app2 = express()

app.use(express.json({limit: '50mb'}));
app.use(express.urlencoded({limit: '50mb'}));

app2.use(express.json({limit: '50mb'}));
app2.use(express.urlencoded({limit: '50mb'}));

app2.listen(3000, function (error) {
    if (error) {
        console.log(error)
    } else {
        console.log('server listening on port ' + Port)
    }
})

function findAddress(curdir, filename) {
    if (fs.existsSync(`${curdir}/${filename}`)) return ''
    if (fs.existsSync(`${curdir}/${filename}.lua`)) return '.lua'
    if (fs.existsSync(`${curdir}/${filename}.client.lua`)) return 'client.lua'
    if (fs.existsSync(`${curdir}/${filename}.server.lua`)) return 'server.lua'

    return null
}

function replaceGame(contents) {
    for (const [key, value] of Object.entries(contents)) {

        function read(curdir, value) {
            if (value.Type == 'ModuleScript' || value.Type == 'LocalScript' || value.Type == 'Script') {
                // scripts and stuff
                var type = value.Type == 'ModuleScript' ? '' : value.Type == 'LocalScript' ? '.client' : value.Type == 'Script' ? '.server' : ''
                console.log(findAddress(curdir, value.Name))
                if (!value.Children && findAddress(curdir, value.Name) === null) {
                    // not parented script
                    console.log(`${curdir}/${value.Name}`)
                    fs.appendFile(`${curdir}/${value.Name}${type}.lua`, value.Source, () => console.log)
                } else {
                    if (
                        !fs.existsSync(`${curdir}/${value.Name}.lua`) &&
                        !fs.existsSync(`${curdir}/${value.Name}.client.lua`) &&
                        !fs.existsSync(`${curdir}/${value.Name}.server.lua`)
                    ) {
                        fs.mkdir(`${curdir}/${value.Name}`, () => console.log)
                    } else {
                        fs.unlink(`${curdir}/${value.Name}${findAddress(curdir, value.Name)}`, () => console.log)

                        //fs.unlink(`${curdir}/${value.Name}`)
                        fs.mkdir(`${curdir}/${value.Name}`, () => console.log)
                    }

                    fs.appendFile(`${curdir}/${value.Name}/${value.Name}${type}.lua`, value.Source, () => console.log)
                }
            } else {
                if (!fs.existsSync(`${curdir}/${value.Name}`)) {
                    fs.mkdir(`${curdir}/${value.Name}`, () => console.log)
                }
            }

            if (value.Children) read(curdir + '/' + value.Name, value.Children)
        }

        read('./game', value)
    }
}

app.post('/', function (req, res) {
    console.log("Syncing")
    const contents = req.body

    replaceGame(contents)

    res.send("success")
})

app.listen(5000, function (error) {
    if (error) {
        console.log(error)
    } else {
        console.log('server listening on port ' + Port)
    }
})

var data = {}

function Read(Dir) {
    let files = fs.readdirSync(Dir)
    var localdata = {}

    // fs.readFileSync(Dir + '\\' + File, 'utf8')
    // fs.writeFileSync('index.json', JSON.stringify(data))

    files.forEach((File) => {
        const Split = File.split('.')
        const LastElement = Dir.split('/').pop()

        if ((LastElement === Split[0] && Split[1] == 'lua') || Split[2] == 'lua' && LastElement === Split[0]) {
            if (Split[1] == 'server') { // test.client.lua || test.server.lua
                localdata['__init__.server.lua'] = fs.readFileSync(Dir + '/' + File, 'utf8')
            } else if (Split[1] == 'client') {
                localdata['__init__.client.lua'] = fs.readFileSync(Dir + '/' + File, 'utf8')
            } else {
                localdata['__init__.lua'] = fs.readFileSync(Dir + '/' + File, 'utf8')
            }

        } else {

            if (Split[1] == 'lua') { // test.lua
                localdata[File] = fs.readFileSync(Dir + '/' + File, 'utf8')
            } else if (Split[2] == 'lua' && Split[1] == 'client' || Split[1] == 'server') { // test.client.lua || test.server.lua
                localdata[File] = fs.readFileSync(Dir + '/' + File, 'utf8')
            }else { // Folder
                localdata[File] = Read(Dir + '/' + File)
            }
        }
    })

    return localdata
}

Object.size = function (obj) {
    var size = 0,
        key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

function ReadIfExist(current, past) {
    if (past.length == 0) return

    var localdata = {}
    for (const [key, value] of Object.entries(past)) {
        var curval = current[key]
        if (key == '__deleted__') continue
        if (typeof value == 'object' && typeof curval == 'object') {
            const content = ReadIfExist(curval, value)
            if (content != null) localdata[key] = content
        } else if (value != curval && typeof value != typeof curval) {
            localdata[key] = 'deleted'
        }
    }

    if (Object.size(localdata) == 0) { return null } else return localdata
}

var previousContent = []

app2.get('/', function (req, res) {
    const content = Read('./game')
    const deletedContents = ReadIfExist(content, previousContent)
    content.__deleted__ = JSON.stringify(deletedContents)
    previousContent = JSON.parse(JSON.stringify(content))

    res.send(JSON.stringify(content))
})