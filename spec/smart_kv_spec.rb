require_relative 'spec_helper'

def safely_swap_constant(original_contstant_str, replacement_constant_str)
  if (klass = Object.const_get(original_constant_str) rescue nil)
    Object.const_set(replacement_constant_str, klass)
    Object.send(:remove_const, original_constant_str.to_sym)
  end
end

RSpec.describe SmartKv do
  it "cannot be instantiated" do
    expect {
      described_class.new({})
    }.to raise_error(SmartKvInitializationError)
  end

  context "Subclass of SmartKv" do
    before(:all) do
      safely_swap_constant("ModelConfig", "AnExtremelyUniqueConstantThatShouldNotExist")

      class ModelConfig < described_class
        required :a_key, :another_key, :and_another
      end
    end

    after(:all) do
      Object.send(:remove_const, :ModelConfig)
      safely_swap_constant("AnExtremelyUniqueConstantThatShouldNotExist", "ModelConfig")
    end

    it "checks whether there are missing required keys" do
      expect {
        ModelConfig.new({
          a_key: "value", and_another: "value again"
        })
      }.to raise_error(KeyError, /missing required key\(s\): `:another_key'/)
    end

    it "doesn't complain when all required keys are there" do
      expect {
        ModelConfig.new({
          a_key: "value", another_key: "another value", and_another: "value again"
        })
      }.not_to raise_error
    end

    it "checks whether keys that are not implemented exist" do
      expect {
        ModelConfig.new({
          a_key: "value", second_key: "value again",
          another_key: "wow.. value", and_another: "excellent"
        })
      }.to raise_error(NotImplementedError, /unrecognized key\(s\): `:second_key'/)
    end

    it "can access the input value from the object" do
      config_1 = ModelConfig.new({
                   a_key: "value", another_key: "another value", and_another: "value again"
                 })

      config_2 = ModelConfig.new(
                   OpenStruct.new({
                     a_key: "value", another_key: "another value", and_another: "value again"
                   })
                 )

      expect(config_1[:a_key]).to eq "value"
      expect(config_1[:another_key]).to eq "another value"
      expect(config_1[:and_another]).to eq "value again"
      expect(config_2.a_key).to eq "value"
      expect(config_2.another_key).to eq "another value"
      expect(config_2.and_another).to eq "value again"
    end

    context "set callable_as to any class that accepts hash as input" do
      before do
        safely_swap_constant("ConvertableConfig", "ALongUniqueConstantThatShouldNotExist")

        class ConvertableConfig < described_class
          required :some_key
          callable_as OpenStruct
        end
      end

      after do
        Object.send(:remove_const, :ConvertableConfig)
        safely_swap_constant("ALongUniqueConstantThatShouldNotExist", "ConvertableConfig")
      end

      it "the instance will be callable as the object set" do
        config = ConvertableConfig.new({some_key: "value"})
        expect { config.some_key }.not_to raise_error
        expect(config.some_key).to eq "value"
        expect(config.object_class).to eq OpenStruct
      end
    end

    context "when required given duplicate keys" do
      before do
        safely_swap_constant("AnotherConfig", "AnotherConstantExtremelyUnlikelyToConflict")

        class AnotherConfig < described_class
          required :duplicate, :duplicate
          optional :also_duplicate, :also_duplicate
        end
      end

      after do
        Object.send(:remove_const, :AnotherConfig)
        safely_swap_constant("AnotherConstantExtremelyUnlikelyToConflict", "AnotherConfig")
      end

      it "registers only the first key as required or optional" do
        expect(AnotherConfig.required_keys).to eq [:duplicate]
        expect(AnotherConfig.optional_keys).to eq [:also_duplicate]
      end
    end

    context "when given a Struct as input" do
      before do
        safely_swap_constant("ConfigStruct", "AnotherExtremelyUniqueConstantThatShouldNotExist")

        ConfigStruct = Struct.new(:a_key, :another_key, :and_another)
      end

      after do
        Object.send(:remove_const, :ConfigStruct)
        safely_swap_constant("AnotherExtremelyUniqueConstantThatShouldNotExist", "ConfigStruct")
      end

      it "accepts the input" do
        expect {
          ModelConfig.new(
            ConfigStruct.new("value", "wow.. value", "excellent")
          )
        }.not_to raise_error
      end
    end

    context "when given an OpenStruct as input" do
      it "accepts the input" do
        expect {
          ModelConfig.new(
            OpenStruct.new({
              a_key: "value", another_key: "wow.. value", and_another: "excellent"
            })
          )
        }.not_to raise_error
      end
    end

    context "optional" do
      before(:all) do
        class ModelConfig
          optional :an_optional_key
        end
      end

      it "allows optional keys" do
        expect {
          ModelConfig.new({
            a_key: "value", another_key: "value 2", and_another: "value again",
            an_optional_key: "I'm optional"})
        }.not_to raise_error
      end

      it "does not complain when optional keys are missing" do
        expect {
          ModelConfig.new({
            a_key: "value", another_key: "value 2", and_another: "value again"
          })
        }.not_to raise_error
      end

      context "when conflicting with existing required keys" do
        before do
          class ModelConfig
            optional :a_key
          end
        end

        it "makes the keys no longer required but allowed (optional)" do
          expect {
            ModelConfig.new({another_key: "1", and_another: "2"})
          }.not_to raise_error
        end
      end
    end
  end

  context "Subclass of Subclass of SmartConfig" do
    before(:all) do
      safely_swap_constant("ChildConfig", "AnotherSuperUniqueConstant")
      safely_swap_constant("GrandChildConfig", "ChildOfAnotherSuperUniqueConstant")

      class ChildConfig < described_class
        required :a_key, :b_key
      end

      class GrandChildConfig < ChildConfig
        required :c_key, :d_key
      end
    end

    after(:all) do
      Object.send(:remove_const, :ChildConfig)
      safely_swap_constant("AnotherSuperUniqueConstant", "ChildConfig")

      Object.send(:remove_const, :GrandChildConfig)
      safely_swap_constant("ChildOfAnotherSuperUniqueConstant", "GrandChildConfig")
    end

    it "inherits the 'required' keys from its parent" do
      expect(ChildConfig.required_keys).to eq [:a_key, :b_key]
      expect(GrandChildConfig.required_keys).to eq [:a_key, :b_key, :c_key, :d_key]
    end
  end
end
