module Sidekiq::Status
# Should be in the client middleware chain
  class ClientMiddleware
    include Storage
    # Uses msg['jid'] id and puts :queued status in the job's Redis hash
    # @param [Class] worker_class if includes Sidekiq::Status::Worker, the job gets processed with the plugin
    # @param [Array] msg job arguments
    # @param [String] queue the queue's name
    def call(worker_class, msg, queue)
      if worker_class.method_defined? :get_job_id
        job_id = worker_class.new.get_job_id(*msg['args'])
        store_status(job_id, :queued)
      end
      yield
    end
  end
end
