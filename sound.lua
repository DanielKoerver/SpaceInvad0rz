sound = {}

sound.entities = {}

sound.playing = {}

sound.defaultVolume = 1
sound.defaultPitch  = 1


function sound.load(soundFile, name)
    sound.entities[name] = love.sound.newSoundData(soundFile)
end


function sound.play(name, volume, pitch)
    local playingSound = love.audio.newSource(sound.entities[name])

    playingSound:setVolume(volume or sound.defaultVolume)
    playingSound:setPitch(pitch or sound.defaultPitch)
    playingSound:play()

    table.insert(sound.playing, playingSound)
end


function sound.clean()
    for i, entity in ipairs(sound.playing) do
        if entity:isStopped() then
            table.remove(sound.playing, i)
        end
    end
end