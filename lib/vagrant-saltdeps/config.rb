module VagrantPlugins
  module Saltdeps
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :checkout_path
      attr_accessor :deps_path
      attr_accessor :grains_path
      attr_accessor :pillars_path
      attr_accessor :merge_pillars
      attr_accessor :merge_grains
      attr_accessor :merged_path

      def initialize
        super
        @machine       = nil
        @checkout_path = UNSET_VALUE
        @deps_path     = UNSET_VALUE
        @grains_path   = UNSET_VALUE
        @pillars_path  = UNSET_VALUE
        @merge_pillars = UNSET_VALUE
        @merge_grains  = UNSET_VALUE
        @merged_path   = UNSET_VALUE
      end

      def validate(machine)
        @machine = machine
        errors = _detected_errors
        if @checkout_path
          Pathname.new(@checkout_path).expand_path(machine.env.root_path)
        else
          @checkout_path = '.saltdeps'
          Pathname.new(@checkout_path).expand_path(machine.env.root_path)
        end

        expand(@deps_path,    errors, true)
        expand(@grains_path,  errors)
        expand(@pillars_path, errors)


        return {"salt provisioner" => errors}
      end

      def finalize!
        @deps_path     = expand('.vagrant-salt/saltdeps.yml') if @deps_path    == UNSET_VALUE
        @grains_path   = '.vagrant-salt/grains'  if @grains_path  == UNSET_VALUE
        @pillars_path  = '.vagrant-salt/pillars' if @pillars_path == UNSET_VALUE
        @merged_path   = '.vagrant-salt'         if @merged_path  == UNSET_VALUE

        @merge_grains  = true if @merge_grains  == UNSET_VALUE
        @merge_pillars = true if @merge_pillars == UNSET_VALUE
      end

      private

      def expand(path, errors=[], check=false)
        expanded = Pathname.new(@deps_path).expand_path(@machine.env.root_path)
        if check && !expanded.file?
          errors << "The file at #{expanded} does not exist. Please give a valid path to your deps.yml file."
        end
      end


    end
  end
end
