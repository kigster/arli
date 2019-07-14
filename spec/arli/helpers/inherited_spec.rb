# frozen_string_literal: true

require 'spec_helper'
module Arli
  module Helpers

    class TestBase
      include ::Arli::Helpers::Inherited
      attr_assignable :blah
      blah 'meh'
    end

    class HorsePlay < ::Arli::Helpers::TestBase
      attr_assignable :moo, :fu, :bar
      moo 'Cow'
      fu 'bar'
      bar 'fu'
    end

    RSpec.describe Inherited do
      before do
      end

      context 'superclass' do
        subject { TestBase }
        its(:blah) { should eq 'meh' }
        its(:short_name) { should eq :test_base }
      end

      context 'subclass' do
        subject { HorsePlay }

        its(:moo) { should eq 'Cow' }
        its(:bar) { should eq 'fu' }
        its(:fu) { should eq 'bar' }
        its(:blah) { should be_nil }
        its(:short_name) { should eq :horse_play }
        context 'assignable attribute from a superclass' do
          before { HorsePlay.blah 'poodle' }
          its(:blah) { should eq 'poodle' }
          after { HorsePlay.blah nil: true }
        end
      end
    end
  end
end
