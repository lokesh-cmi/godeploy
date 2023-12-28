resource "null_resource" "build_image" {

  provisioner "local-exec" {

    command = <<-EOT
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

            # Check if the directory contains a folder called "go"
            if [ -d "go" ]; then
                # Change into the "go" directory
                cd "go"
                # Run the build command
                go mod tidy
                docker build -t $(pwd | awk -F'/' '{print $(NF-1)}') .
                # Change back to the previous directory
                cd ..
            elif [ -f "go.mod" ]; then
                if [ `uname -m` == "arm64" ]
                then
                    docker build --platform=linux/arm64 -t $(pwd | awk -F'/' '{print $(NF)}') .
                else
                    docker build --platform=linux/amd64 -t $(pwd | awk -F'/' '{print $(NF)}') .
                fi
            else
                # If the directory doesn't contain a "go" folder, run the following command
                if [ `uname -m` == "arm64" ]
                then
                    npm run java:docker:arm64
                else
                    npm run java:docker
                fi
            fi            
            # Change back to the original directory
            cd ..
        done

    EOT

    interpreter = ["bash", "-c"]
  }
}
