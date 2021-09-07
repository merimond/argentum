require 'pg'

module Argentum
  class Task
    class DatabaseLogger

      def initialize(name, config)
        @conn = PG.connect config.slice(:dbname, :host, :port, :user, :password)
        @name = name
        @schema = config[:schema]

        setup_task!
        setup_execution!
      end

      def setup_task!
        sql = <<-eos
          INSERT INTO #{@schema}.tasks (name)
          VALUES ($1)
          ON CONFLICT (name) DO UPDATE SET last_run_at = now()
          RETURNING id;
        eos
        @task_id = @conn
          .exec_params(sql, [@name])
          .first["id"]
      end

      def setup_execution!
        sql = <<-eos
          INSERT INTO #{@schema}.executions (task_id)
          VALUES ($1)
          RETURNING id;
        eos
        @execution_id = @conn
          .exec_params(sql, [@task_id])
          .first["id"]
      end

      def log(severity, message)
        sql = <<-eos
          INSERT INTO #{@schema}.messages (execution_id, level, message)
          VALUES ($1, $2, $3)
          RETURNING id;
        eos
        @conn
          .exec_params(sql, [@execution_id, severity, message])
          .first["id"]
      end

      def close
        sql = <<-eos
          UPDATE #{@schema}.executions
          SET completed_at = timezone('UTC'::text, now())
          WHERE id = $1;
        eos
        @conn.exec_params(sql, [@execution_id])
        @conn.finish
      end

      def debug?
        true
      end

      def debug(message)
        log("debug", message)
      end

      def info?
        true
      end

      def info(message)
        log("info", message)
      end

      def error?
        true
      end

      def error(message)
        log("error", message)
      end

      def warn?
        true
      end

      def warn(message)
        log("warn", message)
      end

    end
  end
end
