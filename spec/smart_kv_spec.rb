require_relative 'spec_helper'

RSpec.describe SmartKv do
  it "SmartKv is meant to be inherited" do
    expect {
      SmartKv.check({})
    }.to raise_error(SmartKv::DirectUsageError, /only subclass of SmartKv is meant to be used/)
  end

  context "Subclass of SmartKv" do
    before(:all) do
      class ModelConfig < SmartKv
        required :a_key, :another_key, :and_another
        optional :b_key
      end
    end

    it "checks whether there are missing required keys" do
      expect {
        ModelConfig.check({
          a_key: "value", and_another: "value again"
        })
      }.to raise_error(SmartKv::KeyError, /missing required key\(s\): :another_key/)
    end

    it "doesn't complain when all required keys are there" do
      expect {
        ModelConfig.check({
          a_key: "value", another_key: "another value", and_another: "value again"
        })
      }.not_to raise_error
    end

    it "checks whether keys that are not implemented exist", if: SmartKv::Helper.has_did_you_mean_key_error? do
      expect {
        ModelConfig.check({
          a_key: "value", c_key: "value again",
          another_key: "wow.. value", and_another: "excellent"
        })
      }.to raise_error(SmartKv::KeyError, /unrecognized key: :c_key for ModelConfig.*Did you mean\?/m)
    end

    it "can access the input value from the object" do
      config_1 = ModelConfig.check({
                   a_key: "value", another_key: "another value", and_another: "value again"
                 })

      config_2 = ModelConfig.check(
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

    context 'when inherited from other SmartKv subclass' do
      before do
        class ChildModelConfig < ModelConfig
        end
      end

      it 'will inherit all its optional and required keys' do
        expect(ChildModelConfig.optional_keys).to eq ModelConfig.optional_keys
        expect(ChildModelConfig.required_keys).to eq ModelConfig.required_keys
      end
    end

    context "set callable_as to any class that accepts hash as input" do
      before(:all) do
        class ConvertableConfig < SmartKv
          required :some_key
        end
      end

      context "when callable as is not set" do
        it "callable class is nil" do
          expect(ConvertableConfig.callable_class).to eq nil
        end
      end

      context "when input is a Hash" do
        context "and callable_as is set to OpenStruct" do
          before do
            class ConvertableConfig
              callable_as OpenStruct
            end
          end

          it "the instance will be callable as OpenStruct" do
            config = ConvertableConfig.check({some_key: "value"})
            expect { config.some_key }.not_to raise_error
            expect(config.some_key).to eq "value"
            expect(ConvertableConfig.callable_class).to eq OpenStruct
          end
        end

        context "and callable_as is set to Struct" do
          before do
            class ConvertableConfig
              callable_as Struct
            end
          end

          it "the instance will be callable as instance of Struct" do
            config = ConvertableConfig.check({some_key: "value"})
            expect { config.some_key }.not_to raise_error
            expect(config.some_key).to eq "value"
            expect(config.members).to eq [:some_key]
            expect(ConvertableConfig.callable_class).to eq Struct
          end
        end

        context "and callable_as is set to Instance of Struct" do
          before do
            StructKey = Struct.new(:some_key)
            class ConvertableConfig
              callable_as StructKey
            end
          end

          it "the instance will be callable as instance of Struct" do
            config = ConvertableConfig.check({some_key: "value"})
            expect { config.some_key }.not_to raise_error
            expect(config.some_key).to eq "value"
            expect(config.members).to eq [:some_key]
            expect(ConvertableConfig.callable_class).to eq StructKey
          end
        end
      end

      context "when input is an instance of Struct" do
        before(:all) do
          StructKv = Struct.new(:some_key)
        end

        context "and callable_as is set to Hash" do
          before do
            class ConvertableConfig
              callable_as Hash
            end
          end

          it "the instance will be callable as hash" do
            config = ConvertableConfig.check(StructKv.new("value"))
            expect { config[:some_key] }.not_to raise_error
            expect(config[:some_key]).to eq "value"
            expect(ConvertableConfig.callable_class).to eq Hash
          end
        end

        context "and callable_as is set to OpenStruct" do
          before do
            class ConvertableConfig
              callable_as OpenStruct
            end
          end

          it "the instance will be callable as OpenStruct" do
            config = ConvertableConfig.check(StructKv.new("value"))
            expect { config.some_key }.not_to raise_error
            expect(config.some_key).to eq "value"
            expect(ConvertableConfig.callable_class).to eq OpenStruct
          end
        end
      end

      context "when input is an OpenStruct" do
        before(:all) do
          OstructKv = OpenStruct.new(some_key: "value")
        end

        context "and callable_as is set to Hash" do
          before do
            class ConvertableConfig
              callable_as Hash
            end
          end

          it "the instance will be callable as hash" do
            config = ConvertableConfig.check(OstructKv)
            expect { config[:some_key] }.not_to raise_error
            expect(config[:some_key]).to eq "value"
            expect(ConvertableConfig.callable_class).to eq Hash
          end
        end

        context "and callable_as is set to Struct" do
          before do
            class ConvertableConfig
              callable_as Struct
            end
          end

          it "the instance will be callable as instance of Struct" do
            config = ConvertableConfig.check(OstructKv)
            expect { config.some_key }.not_to raise_error
            expect(config.some_key).to eq "value"
            expect(config.members).to eq [:some_key]
            expect(ConvertableConfig.callable_class).to eq Struct
          end
        end

        context "and callable_as is set to Instance of Struct" do
          before do
            KeyStorage = Struct.new(:some_key)
            class ConvertableConfig
              callable_as KeyStorage
            end
          end

          it "the instance will be callable as instance of Struct" do
            config = ConvertableConfig.check(OstructKv) 
            expect { config.some_key }.not_to raise_error
            expect(config.some_key).to eq "value"
            expect(config.members).to eq [:some_key]
            expect(ConvertableConfig.callable_class).to eq KeyStorage
          end
        end
      end
    end

    context "when required and optional given duplicate keys" do
      before do
        class AnotherConfig < SmartKv
          required :duplicate, :duplicate
          optional :also_duplicate, :also_duplicate
        end
      end

      it "registers only the first key as required or optional" do
        expect(AnotherConfig.required_keys).to eq [:duplicate]
        expect(AnotherConfig.optional_keys).to eq [:also_duplicate]
      end
    end

    context "when given a Struct as input" do
      before do
        ConfigStruct = Struct.new(:a_key, :another_key, :and_another)
      end

      it "accepts the input" do
        expect {
          ModelConfig.check(
            ConfigStruct.new("value", "wow.. value", "excellent")
          )
        }.not_to raise_error
      end
    end

    context "when given an OpenStruct as input" do
      it "accepts the input" do
        expect {
          ModelConfig.check(
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
          ModelConfig.check({
            a_key: "value", another_key: "value 2", and_another: "value again",
            an_optional_key: "I'm optional"})
        }.not_to raise_error
      end

      it "does not complain when optional keys are missing" do
        expect {
          ModelConfig.check({
            a_key: "value", another_key: "value 2", and_another: "value again"
          })
        }.not_to raise_error
      end
    end
  end

  context "conflicting keys" do
    context "when a key made optional after required" do
      before do
        class RequiredToOptional < SmartKv
          required :a_key
          optional :a_key
        end
      end

      it "makes the key no longer required but allowed (optional)" do
        expect {
          RequiredToOptional.new
        }.not_to raise_error
        expect(RequiredToOptional.optional_keys).to eq [:a_key]
        expect(RequiredToOptional.required_keys).to be_empty
      end
    end

    context "when a key made required after optional" do
      before do
        class OptionalToRequired < SmartKv
          optional :b_key
          required :b_key
        end
      end

      it "makes the key no longer optional but required" do
        expect {
          OptionalToRequired.new
        }.to raise_error(SmartKv::KeyError, /missing required key\(s\): :b_key/)
        expect(OptionalToRequired.optional_keys).to be_empty
        expect(OptionalToRequired.required_keys).to eq [:b_key]
      end
    end
  end

  context 'running on production' do
    before do
      class Conf < SmartKv
        required :a, :b, :c
        optional :d, :e
      end
    end

    context 'rails app' do
      before do
        ENV['RAILS_ENV'] = 'production'
      end

      after do
        ENV['RAILS_ENV'] = nil
      end

      context 'when callable_class is Hash' do
        before do
          class Conf
            callable_as Hash
          end
        end

        it "doesn't do strict checking and returns a hash" do
          input_hash = {a: 1, b: 2, f: 6}
          input_ostruct = OpenStruct.new(input_hash)
          expect(Conf.callable_class).to eq Hash
          expect(Conf.check(input_ostruct)).to eq input_hash
        end
      end

      context 'when callable_class is OpenStruct' do
        before do
          class Conf
            callable_as OpenStruct
          end
        end

        it "doesn't do strict checking and returns an OpenStruct object" do
          input_hash = {a: 1, b: 2, f: 6}
          input_ostruct = OpenStruct.new(input_hash)
          expect(Conf.callable_class).to eq OpenStruct
          expect{ Conf.check(input_hash) }.not_to raise_error
          expect(Conf.check(input_hash)).to eq input_ostruct
        end
      end
    end

    context 'rack app' do
      before do
        ENV['RACK_ENV'] = 'production'
      end

      after do
        ENV['RACK_ENV'] = nil
      end

      context 'when callable_class is Hash' do
        before do
          class Conf
            callable_as Hash
          end
        end

        it "doesn't do strict checking and returns a hash" do
          input_hash = {a: 1, b: 2, f: 6}
          input_ostruct = OpenStruct.new(input_hash)
          expect(Conf.callable_class).to eq Hash
          expect{ Conf.check(input_ostruct) }.not_to raise_error
          expect(Conf.check(input_ostruct)).to eq input_hash
        end
      end

      context 'when callable_class is OpenStruct' do
        before do
          class Conf
            callable_as OpenStruct
          end
        end

        it "doesn't do strict checking and returns an OpenStruct object" do
          input_hash = {a: 1, b: 2, f: 6}
          input_ostruct = OpenStruct.new(input_hash)
          expect(Conf.callable_class).to eq OpenStruct
          expect(Conf.check(input_hash)).to eq input_ostruct
        end
      end
    end
  end

  context "Subclass of Subclass of SmartConfig" do
    before(:all) do
      class ChildConfig < SmartKv
        required :a_key, :b_key
      end

      class GrandChildConfig < ChildConfig
        required :c_key, :d_key
      end
    end

    it "inherits the 'required' keys from its parent" do
      expect(ChildConfig.required_keys).to eq [:a_key, :b_key]
      expect(GrandChildConfig.required_keys).to eq [:a_key, :b_key, :c_key, :d_key]
    end
  end
end
