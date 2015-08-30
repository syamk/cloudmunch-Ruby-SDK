#!/usr/bin/ruby
require 'logger'
require 'json'
#require_relative 'get_json_args.rb'


module Util
   def Util.logInit(logFilename)
      logger = Logger.new(logFilename)
      return logger
   end

   def Util.log(logger, level, logString)
      case level
         when "fatal"
            logger.fatal(logString)
         when "errror"
            logger.error(logString)
         when "warn"
            logger.warn(logString)
         when "info"
            logger.info(logString)
         when "debug"  
            logger.debug(logString) 
         else
            logger.unknown(logString)   
      end
      puts "["+level+"]: "+logString
      logger.level
   end

   def Util.logClose(logger)
      logger.close
   end

   def Util.getJSONArgsTEMP(jsonString)
      JSON.parse(jsonString)
   end

   def Util.getJSONArgs()
      jsonin = nil
      loop { case ARGV[0]
          when '-jsoninput' then  ARGV.shift; jsonin = ARGV.shift
          when /^-/ then  usage("Unknown option: #{ARGV[0].inspect}")
          else break
      end; }
      return JSON.load(jsonin); 
   end

   def Util.openJSONFile(fileNameWithPath)
      begin
        config = JSON.load(File.open(fileNameWithPath))
        return config
      rescue
         return false
      end
   end
   
   def Util.generateReport(reportFileName, reportContent)
      begin
        fp=File.new(reportFileName, 'w')
        fp.write(reportContent)
        fp.close
        return true
      rescue
        # puts "Could not open output file #{input_json['reporthtml']} Check that the files exists and you have permissions to open the file!"
        # exit 1
        return false
      end
   end
   
   def Util.getSortedSprints(server, endpoint, params)
        sprints = []
        sname_by_sequence = {}
        tseq = []

        newParam = {
            :action => 'listcustomcontext',
            :fields => 'sequence, sprint_id',
            :group_by => 'sequence',
            :count => '*'
        }

        newParam = params.merge(newParam)
        cqlQuery = CloudmunchService.getDataContext(server, endpoint, newParam)
        cqlQuery = JSON.parse(cqlQuery)
        cqlQuery.each do |v|
            # puts v[1]
            tseq << v[1]['sequence'].to_i
            sname_by_sequence[v[1]['sequence'].to_i] = v[1]['sprint_id']
        end

        tseq.sort!.each do |y|
            sprints << sname_by_sequence[y]
        end

        return sprints
    end

    def Util.getActiveSprint(server, endpoint, params)
        sprints = []

        newParam = {
            :action => "listcustomcontext",
            :fields => "sprint_id,sprint_status",
            :sort_by => "sprint_status",
            :count => "*",
        }

        newParam = params.merge(newParam)
        cqlQuery = CloudmunchService.getDataContext(server, endpoint, newParam)
        cqlQuery = JSON.parse(cqlQuery)
        sprint = nil
        cqlQuery.each do |x|
            if(x['sprint_status'] == 'ACTIVE')
                sprint = x['sprint_id']
            end
        end
        return sprint
   end
    
end

