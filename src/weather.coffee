# Description
#   Obtains the current or weekly forecast from the Dark Sky API.
#
# Configuration
#   DARK_SKY_API_KEY
#
# Commands:
#   hubot weather <location> - retrieve the current temperature and summary
#   hubot forecast <location> - retrieve the weekly forecast
#
# Author:
#   Justin Haupt



googleUrl = "http://maps.googleapis.com/maps/api/geocode/json"
darkskyUrl = "https://api.forecast.io/forecast/" + process.env.DARK_SKY_API_KEY + "/"


module.exports = (robot) ->

    #When the topic of weather appears in conversation
    robot.hear /sunny|stormy|rainy|cloudy|sun|rain|hail|windy/i, (msg) ->
        msg.send "Does anyone need the weather forecast? Huh? Yeah?"
    
    
    #On input: hubot weather <city>
    robot.respond /weather (.*)/i, (msg) ->
        location = msg.match[1]
        getLocation(msg, location, getWeather)
    
    
    #On input: weatherbot forecast <city>    
    robot.respond /forecast (.*)/i, (msg) ->
        location = msg.match[1]
        getLocation(msg, location, getForecast)


    #Retrieve the city's coordinates from Google maps
    getLocation = (msg, location, cb) ->
        return msg.send "No DARKSKY_API_KEY set" if not process.env.DARK_SKY_API_KEY
        msg.http(googleUrl).query(address: location, sensor: true).get() (err, res, body) ->
            try
                result = JSON.parse(body)
                coordinates = result.results[0].geometry.location
            catch err
                msg.send "Cannot not find #{location}"
                return null
            cb(msg, location, coordinates)


    #Retrieve the current weather for a location
    getWeather = (msg, location, coordinates) ->
    
        url = darkskyUrl + coordinates.lat + "," + coordinates.lng

        msg.http(url).query(units: 'us').get() (err, res, body) ->
            return msg.send "Could not get weather data" if err
            try
                result = JSON.parse(body)
            catch err
                return msg.send "Could not parse weather data"
            temperature = result.currently.temperature + "ºF"
            msg.send "Currently in #{location}: #{temperature} #{result.currently.summary}"

    

    #Retrieve the weekly forecast for a location
    getForecast = (msg, location, coordinates) ->
    
        url = darkskyUrl + coordinates.lat + "," + coordinates.lng
        
        msg.http(url).query(units: 'us').get() (err, res, body) ->
            return msg.send "Could not get weather forecast" if err
            try
                result = JSON.parse(body)
                daily = result.daily.data
            catch err
                return "Could not parse weather data"
            msg.send "The week's forecast for #{location}:"
            for i in [0..6]
                date = new Date(daily[i].time * 1000)
                month = date.getMonth() + 1
                day = date.getDate()
                min = daily[i].temperatureMin + "ºF"
                max = daily[i].temperatureMax + "ºF"
                msg.send "#{month}/#{day}: Low of #{min} High of #{max}   #{daily[i].summary}"


    
    
    
    
    
    
    
    
    
        
    