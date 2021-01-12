# This class installs the hashicorp repository
#
# @summary Set up the package repository for the HashiCorp Stack components
#
# @example
#   include hashi_stack::repo
#
# @param priority A numeric priority for the repo, passed to the package management system
# @param proxy The URL of a HTTP proxy to use for package downloads (YUM only)
# @param base_repo_url The base url for the repo path
class hashi_stack::repo (
  Optional[Integer] $priority      = undef,
  String            $proxy         = 'absent',
) {
  $key_id='E8A032E094D8EB4EA189D270DA418C88A3219F7B'
  $key_source='https://apt.releases.hashicorp.com/gpg'
  $description='HashiCorp package repository.'

  case $facts['os']['family'] {
    'Debian': {
      include apt

      apt::source { 'HashiCorp':
        ensure       => 'present',
        architecture => 'amd64',
        comment      => $description,
        location     => 'https://apt.releases.hashicorp.com',
        release      => 'stable',
        repos        => 'main',
        key          => {
          'id'     => $key_id,
          'source' => $key_source,
        },
        include      => {
          'deb' => true,
          'src' => false,
        },
        pin          => $priority,
      }
    }
    'RedHat': {
      yumrepo { 'HashiCorp':
        descr    => $description,
        baseurl  => 'https://rpm.releases.hashicorp.com/RHEL/$releasever/$basearch/stable',
        gpgcheck => 1,
        gpgkey   => $key_source,
        enabled  => 1,
        proxy    => $proxy,
        priority => $priority,
      }
    }
    default: {
      fail("\"${module_name}\" provides no repository information for OSfamily \"${facts['os']['family']}\"")
    }
  }
}