require 'json'
require 'aws-sdk-ecs'

TASK_KEYS = [:family, :task_role_arn, :execution_role_arn, :network_mode, :container_definitions, :volumes, :placement_constraints, :requires_compatibilities, :cpu, :memory, :tags]

def lambda_handler(event:, context:)
    client = Aws::ECS::Client.new(region: "ap-northeast-1")
    
    resp = client.describe_task_definition({
        task_definition: "#{ENV["BaseTaskDefinition"]}",
    })
    req_params = resp[:task_definition].to_h.select{|key,_val| TASK_KEYS.include?(key)}.to_h
    
    app_containr = req_params[:container_definitions].select{|containr| containr[:name] == ENV["AppContainerName"]}.first
    
    image_base = app_containr[:image].split("@").first.split(":")
    
    app_containr[:image] = [image_base[0],ENV["ImageTag"]].join(":")
    
    app_containr[:port_mappings] = []
    
    app_containr[:log_configuration][:options]["awslogs-stream-prefix"] = "migrate_task"
    
    app_containr[:command] = ENV["MigrateCommand"].split(",")
    
    req_params[:container_definitions] = [app_containr]
    
    req_params[:family] = ENV["MigrateTaskDefinition"]
    
    client.register_task_definition(req_params)
end

