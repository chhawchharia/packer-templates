# Test 04: Java Development Environment
# Installs OpenJDK, Maven, and Gradle

variable "java_version" {
  type        = string
  default     = "17"
  description = "Java major version"
}

variable "maven_version" {
  type        = string
  default     = "3.9.6"
  description = "Maven version"
}

variable "gradle_version" {
  type        = string
  default     = "8.5"
  description = "Gradle version"
}

provisioner "shell" {
  inline = [
    "echo '=== Installing Java ${var.java_version} ==='",
    "export DEBIAN_FRONTEND=noninteractive",
    
    "sudo apt-get update",
    "# Install Java and common tools (unzip needed for Gradle)",
    "sudo apt-get install -y openjdk-${var.java_version}-jdk openjdk-${var.java_version}-jre unzip curl",
    
    "# Set JAVA_HOME",
    "echo 'JAVA_HOME=/usr/lib/jvm/java-${var.java_version}-openjdk-amd64' | sudo tee -a /etc/environment",
    "echo 'export JAVA_HOME=/usr/lib/jvm/java-${var.java_version}-openjdk-amd64' | sudo tee /etc/profile.d/java.sh",
    "echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile.d/java.sh",
    
    "java -version",
    "javac -version",
    
    "echo '=== Java installed ==='"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Installing Maven ${var.maven_version} ==='",
    
    "cd /tmp",
    "curl -fsSL https://archive.apache.org/dist/maven/maven-3/${var.maven_version}/binaries/apache-maven-${var.maven_version}-bin.tar.gz -o maven.tar.gz",
    "sudo tar -xzf maven.tar.gz -C /opt/",
    "sudo ln -sf /opt/apache-maven-${var.maven_version} /opt/maven",
    "rm maven.tar.gz",
    
    "# Add to PATH",
    "echo 'export M2_HOME=/opt/maven' | sudo tee /etc/profile.d/maven.sh",
    "echo 'export PATH=$PATH:$M2_HOME/bin' | sudo tee -a /etc/profile.d/maven.sh",
    "sudo chmod +x /etc/profile.d/maven.sh",
    
    "/opt/maven/bin/mvn --version",
    
    "echo '=== Maven installed ==='"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Installing Gradle ${var.gradle_version} ==='",
    
    "cd /tmp",
    "curl -fsSL https://services.gradle.org/distributions/gradle-${var.gradle_version}-bin.zip -o gradle.zip",
    "sudo unzip -q gradle.zip -d /opt/",
    "sudo ln -sf /opt/gradle-${var.gradle_version} /opt/gradle",
    "rm gradle.zip",
    
    "# Add to PATH",
    "echo 'export GRADLE_HOME=/opt/gradle' | sudo tee /etc/profile.d/gradle.sh",
    "echo 'export PATH=$PATH:$GRADLE_HOME/bin' | sudo tee -a /etc/profile.d/gradle.sh",
    "sudo chmod +x /etc/profile.d/gradle.sh",
    
    "/opt/gradle/bin/gradle --version",
    
    "echo '=== Gradle installed ==='"
  ]
}

provisioner "shell" {
  inline = [
    "echo '=== Final verification ==='",
    "source /etc/profile.d/java.sh",
    "source /etc/profile.d/maven.sh",
    "source /etc/profile.d/gradle.sh",
    "echo 'Java:' && java -version 2>&1 | head -1",
    "echo 'Maven:' && /opt/maven/bin/mvn --version | head -1",
    "echo 'Gradle:' && /opt/gradle/bin/gradle --version | head -3",
    "echo '=== All done ==='"
  ]
}

