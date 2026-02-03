class SuperAdmin::MigrationsController < SuperAdmin::BaseController
  def create
    output = []
    exit_status = nil

    IO.popen(["bin/rails", "db:migrate"], err: [:child, :out]) do |io|
      io.each_line { |line| output << line }
    end
    exit_status = $?.exitstatus

    if exit_status.zero?
      flash[:notice] = "Migrations appliquées avec succès."
    else
      flash[:alert] = "Échec des migrations (code #{exit_status})."
    end

    @migration_output = output.join
    render "super_admin/migrations_result"
  end
end
