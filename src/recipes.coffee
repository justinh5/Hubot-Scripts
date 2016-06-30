# Description:
#   Retrieves recipes with the Yummly API. A picture, name, and url are
#   displayed for each result. Recipes with specific ingredients may
#   also be requested.
#
# Configuration:
#   YUMMLY_ID -- Yummly account ID
#   YUMMLY_API_KEY -- Yummly API key
#
# Commands:
#   hubot recipe help
#   hubot search recipes <recipe>
#   hubot search recipes <recipe> with <ingredient1, ingredient2, ...>
#
# Author:
#   Justin Haupt


yummlyUrl = "http://api.yummly.com/v1/api/recipes?_app_id=" + 
             process.env.YUMMLY_ID + "&_app_key=" + process.env.YUMMLY_API_KEY + "&q="
recipesDisplayed = 5



module.exports = (robot) ->
  
    robot.hear /food|eating|cook|cooking|bake/i, (msg) ->
        msg.send "I can search recipes for you through Yummly if you'd like. Type 'hubot recipe help'"
    
    
    #On input: hubot recipe help
    robot.respond /(recipe|recipes) help/i, (msg) ->
        msg.send "Yummly recipe search options:
                 \nhubot recipe help
                 \nhubot search recipes <recipe>
                 \nhubot search recipes <recipe> with <ingredient1, ingredient2, ...>" 
    
    
    #A list of recipes is requested with an optional list of ingredients
    robot.respond /search recipe(s)? (.*)( with (.*))?/i, (msg) ->
        recipe = msg.match[2]
        ingredients = msg.match[4]
        getRecipe(msg, recipe, ingredients)
        
    
    
#Retrieves a list of recipes for a recipe search
getRecipe = (msg, recipe, ingredients) ->

    #detect if the Yummly ID and API key are configured
    return msg.send "No YUMMLY_ID set" if not process.env.YUMMLY_ID
    return msg.send "No YUMMLY_API_KEY set" if not process.env.YUMMLY_API_KEY

    #establish the url in case specific ingredients are requested
    if ingredients
        ingredientsEdit = null
        temp = null
        for i in ingredients
            if ingredients[i] is not "," | "\s"
                temp += ingredients[i]
            else
                ingredientsEdit += "&allowedIngredient[]=#{temp}"
        url = yummlyUrl + recipe + ingredientsEdit
    else
        url = yummlyUrl + recipe  
                

    msg.http(url).get() (err, res, body) ->
        return msg.send 'Could not find any recipes' if err
        try
            result = JSON.parse(body)
            matches = result.matches
        catch err
            return msg.send "Could not parse recipe data."
        if result.totalMatchCount == 0
            return msg.send "There are no recipes for #{recipe}"
        
        msg.send "Here are the top five recipes for #{recipe}:"
        for i in [0..(recipesDisplayed-1)]
            try
                msg.send "\n\n#{matches[i].recipeName} - http://yummly.com/recipe/#{matches[i].id}
                          \n#{matches[i].smallImageUrls[0]}"
            catch err
                return
    
    
    
    
    
    