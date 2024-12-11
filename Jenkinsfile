pipeline {
    agent { label 'docker-agent-debian' }
    environment {
        GITHUB_REPO = "etzionas/dev-ops-api-example"
        GITHUB_TOKEN = credentials('github_token') // GitHub token from Jenkins credentials
        REPO_OWNER = 'etzionas'
        REPO_NAME = 'dev-ops-api-example'
        DOCKER_AGENT_IMAGE = "ghcr.io/${REPO_OWNER}/${REPO_NAME}:1.0.0"
    }
    triggers{
        GenericTrigger(
            genericVariables: [
                [key: 'workflow_run_status', value: '$.action'],
                [key: 'workflow_run_id', value: '$.workflow_run.id']
            ],
            token: 'github-webhook-secret',
            causeString: 'Triggered by workflow_run event',
            printContributedVariables: true,
            printPostContent: true,
            regexpFilterExpression: '^completed$', // Only trigger when the workflow is finished
            regexpFilterText: '$workflow_run_status' 
        )
    }
    stages {
        stage('Prepare Environment') {
            steps {
                // Check if unzip is installed and install it only if missing
                def unzipInstalled = sh(script: "dpkg -l | grep -qw unzip", returnStatus: true) == 0
                if (!unzipInstalled) {
                    echo 'Unzip is not installed. Installing unzip...'
                    sh 'apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*'
                } else {
                    echo 'Unzip is already installed.'
                }
            }
        }
        stage('Fetch GitHub Action Logs') {
            steps {
                script {
                    def workflowRunId = env.workflow_run_id
                    // if (!workflowRunId) {
                    //     error "Workflow run ID not provided in webhook payload."
                    // }
                    
                    echo "Fetching logs for Workflow Run ID: ${workflowRunId}"

                    // Fetch latest workflow run details
                    def response = sh(script: """
                        curl -s -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                        https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs
                        """, returnStdout: true).trim()

                    // Download the logs
                    sh """
                        curl -s -L -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                        https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs/${workflowRunId}/logs \
                        -o logs.zip
                    """
                    // // Unzip and display logs
                    sh 'unzip -o logs.zip -d logs && cat logs/**/*.txt'
                }
            }
        }
    }
}
