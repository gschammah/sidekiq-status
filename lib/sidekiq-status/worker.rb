module Sidekiq::Status::Worker
  include Sidekiq::Status::Storage

  class Stopped < StandardError
  end

  attr_accessor :expiration

  def set_job_id(model)
    @job_id = Sidekiq::Status.get_job_id(model)
  end

  # Stores multiple values into a job's status hash,
  # sets last update time
  # @param [Hash] status_updates updated values
  # @return [String] Redis operation status code
  def store(hash)
    store_for_id @job_id, hash, @expiration
  end

  # Read value from job status hash
  # @param String|Symbol hask key
  # @return [String]
  def retrieve(name)
    read_field_for_id @job_id, name
  end

  # Sets current task progress
  # (inspired by resque-status)
  # @param Fixnum number of tasks done
  # @param Fixnum total number of tasks
  # @param String optional message
  # @return [String]
  def at(num, total, message=nil)
    store({num: num, total: total, message: message})
  end

  def incr(field, increment = 1)
    Sidekiq.redis do |conn|
      conn.hincrby(@job_id, field, increment)
    end
  end

end
