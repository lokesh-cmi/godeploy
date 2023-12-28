resource "null_resource" "push_image_to_docker_hub" {

 provisioner "local-exec" {
    
    command = <<-EOT
        # docker cli must be installed and configured
        docker login

        # shifting to root directory
        cd ../../

        # Iterate over each directory
        for dir in */ ; do 
            # Check if the directory name matches a certain pattern
            if [[ "$dir" == "kubernetes/" || "$dir" == "terraform/" || "$dir" == "blueprints/" ]]; then
                echo "SKIPPING THIS DIR:-" $dir
                # If it matches, skip to the next directory
                continue
            fi
            # Change into the directory
            cd "$dir"
            
            echo "CURRENT DIR:-" $(pwd)

            # Execute the command

            current_dir=$(pwd)
            current_dir_name=$(basename $current_dir)

            # provide region and account-id
            docker tag $current_dir_name:latest ${var.docker_repository_name}/$current_dir_name:latest
            docker push ${var.docker_repository_name}/$current_dir_name:latest

            # Change back to the original directory
            cd ..
        done

    EOT

    interpreter = ["bash", "-c"]
  }
  depends_on = [
    null_resource.build_image
  ]
}
