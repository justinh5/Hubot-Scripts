# Description:
#   Keeps a pet cat on your team. 
#
# Dependencies:
#   "moment": "^2.13.0"
#
# Configuration:
#   None
#
# Commands:
#   hubot cat help - returns a list of cat commands
#   hubot adopt cat - adopt a new cat
#   hubot name cat <name> - give a name to the cat
#   hubot check cat - see what the cat looks like
#   hubot pet cat - pets the cat
#   hubot play (with) cat - play with the cat
#   hubot feed cat - feeds the cat
#   hubot walk cat - take the cat for a walk
#   hubot tease cat - make the cat dislike you
#   hubot destroy cat - destroys the cat (for emergencies only)
#
# Author:
#   Justin Haupt


moment = require 'moment'


module.exports = (robot) ->

    #Access to hubot's memory
    memory = () -> robot.brain.data.remember ?= {}
    
    
    #Check if a cat is already owned
    catOwned = (msg) -> 
        check = false if not memory()["score"]?
        if check == false
            msg.send "You don't have a cat!"
        return check
     
     
    #When words similar to 'cat' appear in the channel
    robot.hear /kitty|kitten|catnip|katniss|kit-kat|bobcat|ocelot/i, (msg) ->
        if memory()["score"]? == false then return    #check if there is a cat
        msg.send "#{memory()["name"]}: Meow!"
    
    
    #Returns a list of cat commands
    robot.respond /cat help/i, (msg) ->
        help = "\nCommands:\n  hubot cat help\n  hubot adopt cat
                \n  hubot name cat <name>\n  hubot check cat
                \n  hubot pet cat\n  hubot play (with) cat
                \n  hubot feed cat\n  hubot walk cat
                \n  hubot tease cat\n  hubot destroy cat (for emergencies only)"
        msg.send "#{help}"
        

    #Adopt a new cat
    robot.respond /adopt cat/i, (msg) ->
        if memory()["score"]?
            return msg.send "You already have a cat!"   
        else
            memory()["score"] = "0"        #initialize the cat's happiness rating
            memory()["name"] = "the cat"   #initialize the default name
            msg.send "You adopted a new cat! Use 'hubot cat help' to learn commands."
    
    
    #Gives the cat an optional name
    robot.respond /name cat (.*)/i, (msg) ->
        if catOwned(msg) == false then return
        value = msg.match[1]
        memory()["name"] = value
        msg.send "The cat's name is now #{memory()["name"]}"
      
      
    #See what the cat looks like
    robot.respond /check cat/i, (msg) ->
        if catOwned(msg) == false then return
        if 0 <= memory()["score"] < 5
            msg.send "https://pixabay.com/static/uploads/photo/2014/08/28/19/58/cat-430051_960_720.jpg"
        else if memory()["score"] >= 5
            msg.send "http://www.lions.org/images/bengal.jpg"
        else
            msg.send "https://cdn.burst.zone/wp-content/uploads/2013/01/grumpy-confused-cat.jpg"
        
        
    #Pet the cat
    robot.respond /pet cat/i, (msg) ->
        if catOwned(msg) == false then return
        if memory()["score"] >= 0 
            message = "#{memory()["name"]} purs softly."
            ++memory()["score"]
        else
            message = "#{memory()["name"]} acts as if you don't exist."
        msg.send "#{message}"
    
  
    #Play with the cat
    play = [
        "The cat chases a green laser dot is circles. Aww.",
        "You climb a tree with the cat. Neither of you knows how to get back down.",
        "You practice your secret handshake with the cat."
        ]
    robot.respond /play( with)? cat/i, (msg) ->
        if catOwned(msg) == false then return
        if memory()["score"] >= 0 
            message = msg.random play
            ++memory()["score"]
        else
            message = "#{memory()["name"]} hisses and darts out of the room."
        msg.send "#{message}"
        
   
    #Feed the cat. Checks if the cat has already been fed today.
    robot.respond /feed cat/i, (msg) ->
        if catOwned(msg) == false then return
        time = moment().format("DD MM YYYY")
        if memory()["time"] == time
            msg.send "You have already fed the cat today!"
            return
        else
            message = "A can of cat-food is opened and placed on the floor."
            if memory()["score"] >= 0 
                message += "\n#{memory()["name"]} daintily nips at the chunks."
            else
                message += "\n#{memory()["name"]} glares at you, then begins eating."
            
            memory()["time"] = time   #record the date of the feeding
            ++memory()["score"]
            msg.send "#{message}"
    
        
    #Walk the cat
    robot.respond /walk cat/i, (msg) ->
        if catOwned(msg) == false then return
        if memory()["score"] >= 0 
            message = "You clip a leash on #{memory()["name"]} and go out for a stroll."
        else
            message = "#{memory()["name"]} hisses and darts out of the room."
        msg.send "#{message}"
        
 
    #Tease the cat
    teases = [
        "You dangle a mackeral out of the cat's reach.",
        "You poke the cat. It looks unamused.",
        "You make a silly face in front of the cat. It scratches your face. Ouch."
        ]
    robot.respond /tease cat/i, (msg) ->
        if catOwned(msg) == false then return
        --memory()["score"]
        msg.send msg.random teases

 
    #Destroy the cat
    robot.respond /destroy cat/i, (msg) ->   
        if catOwned(msg) == false then return
        delete memory()["name"]
        delete memory()["score"]
        delete memory()["time"]
        message = "You have discovered that your cat has been plotting to exterminate
                  \nthe human race, so you take a hatchet do what needs to be done."
        msg.send "#{message}"
    
    
    
    
    
    
    
    
    
    
    