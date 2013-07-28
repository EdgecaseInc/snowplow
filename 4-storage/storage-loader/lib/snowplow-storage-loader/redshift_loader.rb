# Copyright (c) 2012-2013 Snowplow Analytics Ltd. All rights reserved.
#
# This program is licensed to you under the Apache License Version 2.0,
# and you may not use this file except in compliance with the Apache License Version 2.0.
# You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the Apache License Version 2.0 is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.

# Author::    Alex Dean (mailto:support@snowplowanalytics.com)
# Copyright:: Copyright (c) 2012-2013 Snowplow Analytics Ltd
# License::   Apache License Version 2.0

# Ruby module to support the load of SnowPlow events into Redshift
module SnowPlow
  module StorageLoader
    module RedshiftLoader

      # Constants for the load process
      EVENT_FIELD_SEPARATOR = "\\t"

      # Loads the SnowPlow event files into Redshift.
      #
      # Parameters:
      # +config+:: the hash of configuration options
      def load_events(config)
        puts "Loading Snowplow events into Redshift..."

        # Assemble the relevant parameters for the bulk load query
        credentials = "aws_access_key_id=#{config[:aws][:access_key_id]};aws_secret_access_key=#{config[:aws][:secret_access_key]}"
        queries = ["COPY #{config[:storage][:table]} FROM '#{config[:s3][:buckets][:in]}' CREDENTIALS '#{credentials}' DELIMITER '#{EVENT_FIELD_SEPARATOR}' MAXERROR #{config[:storage][:max_error]} EMPTYASNULL",
                   "ANALYZE #{config[:storage][:table]}",
                   "VACUUM SORT ONLY #{config[:storage][:table]}"]

        status = PostgresLoader.execute_queries(config, queries)
        unless status == []
          raise DatabaseLoadError, "#{status[1]} error executing #{status[0]}: #{status[2]}"
        end
      end
      module_function :load_events

    end
  end
end
