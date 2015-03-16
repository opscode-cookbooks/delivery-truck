#
# Copyright:: Copyright (c) 2012-2015 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module DeliveryTruck
  class Error < RuntimeError; end

  # Raise this when a `.delivery/config.json` file doesn't actually
  # exist.
  class MissingConfiguration < Error
    def initialize(path)
      @path = path
    end

    def to_s
      <<-EOM
Could not find a Delivery configuration file at:
#{@path}
      EOM
    end
  end

  # Raise when a cookbook said to be a cookbook is not a valid cookbook
  class NotACookbook < Error
    def initialize(path)
      @path = path
    end

    def to_s
      <<-EOM
The directory below is not a valid cookbook:
#{@path}
      EOM
    end
  end

  # If we do not have the change information yet lets report it
  class MissingChangeInformation < Error
    def initialize(message)
      @message = message
    end

    def to_s
      <<-EOM
At this point there is no Change Information loaded.
Extra Details:
#{@message}
EOM
    end
  end
end