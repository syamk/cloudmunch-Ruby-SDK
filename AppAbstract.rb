#!/usr/bin/ruby
$LOAD_PATH << '.'

require_relative "CloudmunchService"
require_relative "Util"
require_relative "ServiceProvider"
require_relative "AppContext"

class AppAbstract
    include CloudmunchService
    include Util
    include UtilJira

    @@config_path = ENV["SDK_CONFIG_PATH"]+"/sdk_config.json"
    @@config = nil

    @@appLevelConstant = 0


    def logInit(log_level)
        @logger = Util.logInit()
        @log_level = log_level
    end

    def logIt(level,logString)
        Util.logIt(@logger, @log_level, level, logString)
    end
    
    def logClose()
        Util.logClose(@logger)
    end
    
    def getServerName
        @@masterServerName
    end

    def getServerEndpoint
        @@masterEndpoint
    end



    def logInit(logfile)
        @logger = Util.logInit(logfile)
    end

    def log(level,logString)
        Util.log(@logger, level, logString)
    end

    def logClose()
        Util.logClose(@logger)
    end

    def getJSONArgs()
        Util.getJSONArgs()
    end

    def openJSONFile(fileNameWithPath)
        Util.openJSONFile(fileNameWithPath)
    end

    def generateReport(reportFilename, reportString)
        Util.generateReport(reportFilename, reportString)
    end
    
    def getServiceProvider()
        @json_input = @json_input ? @json_input : getJSONArgs()
        serviceProvider = ServiceProvider.new(@json_input["providername"])
        serviceProvider.load_data(@json_input)
        return serviceProvider
    end
    
    def getAppContext()
        @json_input = @json_input ? @json_input : getJSONArgs()
        appContext = AppContext.new(@json_input)
        return appContext
    end

    def getDataContextFromCMDB(param)
        appContext = getAppContext()
        params = {
            "username" => @@config['username'],
            "customcontext" => param["project"] + "_" + param["context"],
            "action" => "listcustomcontext"
        }
        param.delete("context")
        params = param.merge(params)

        return CloudmunchService.getDataContext(appContext.get_data('masterurl'), @@config["endpoint"], params)
    end

    def updateDataContextToCMDB(param)
        appContext = getAppContext()
        params = {
            "username" => @@config['username'],
            "customcontext" => param["project"] + "_" + param["context"],
            "action" => "updatecustomcontext"
        }
        param.delete("context")
        params = param.merge(params)
        return CloudmunchService.updateDataContext(appContext.get_data('masterurl'), @@config['endpoint'], params)
    end

    def getActiveSprint(param)
        params = {
            :username => @@config['username']
        }
        puts params.to_s
        params = param.merge(params)
        UtilJira.getActiveSprint(@@config['master_url'], @@config['endpoint'], params)
    end

    def getSortedSprints(param)
        params = {
            :username => @@config['username']
        }

        params = param.merge(params)

        UtilJira.getSortedSprints(@@config['master_url'], @@config['endpoint'], params)
    end

    def getUrlForViewCards(param)
        params = {
            :username => @@config['username']
        }

        params = param.merge(params)

        UtilJira.getUrlForViewCards(@@config['master_url'], @@config['endpoint'], params)
    end

    def getCMContext(context)
        begin
            return @@config[context+"_context"]
        rescue
            return false
        end
    end

    def load_config()
        @@config = openJSONFile(@@config_path)
    end

    def initializeApp()
        puts "initializeApp from AppAbstract"
    end

    def process()
        puts "process func from AppAbstract"
    end

    def cleanupApp()
        puts "cleanupApp from AppAbstract"
    end

    def start()
        load_config()
        initializeApp()
        process()
        cleanupApp()
    end

    private :load_config

end
