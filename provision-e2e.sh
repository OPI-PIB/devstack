set -e
set -o pipefail
set -x

if [ -z "$DEVSTACK_WORKSPACE_NAVOICA" ]; then
    DEVSTACK_WORKSPACE_NAVOICA=..
elif [ ! -d "$DEVSTACK_WORKSPACE_NAVOICA" ]; then
    echo "Workspace directory $DEVSTACK_WORKSPACE_NAVOICA doesn't exist"
    exit 1
fi

# Copy the test course tarball into the studio container
docker cp ${DEVSTACK_WORKSPACE_NAVOICA}/edx-e2e-tests/upload_files/course.tar.gz navoica.navoica-devstack.studio:/tmp/

# Extract the test course tarball
docker-compose exec studio bash -c 'cd /tmp && tar xzf course.tar.gz'

# Import the course content
docker-compose exec studio bash -c 'source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/navoica-platform/manage.py cms --settings=devstack_docker import /tmp course'

# Clean up the temp files
docker-compose exec studio bash -c 'rm /tmp/course.tar.gz'
docker-compose exec studio bash -c 'rm -r /tmp/course'
