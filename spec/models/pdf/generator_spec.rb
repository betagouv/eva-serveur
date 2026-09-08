require 'rails_helper'

class FakePuppeteerPage
  include Puppeteer::EventCallbackable
end

describe Pdf::Generator do
  let(:generator) { described_class.new }
  let(:page) { FakePuppeteerPage.new }

  describe '#attend_reseau_stabilise' do
    it "se resout rapidement quand aucune requete n'est en cours" do
      duree = Benchmark.realtime do
        generator.send(:attend_reseau_stabilise, page, idle_time: 10, timeout: 500)
      end

      expect(duree).to be < 0.5
    end

    it 'se resout via "response" meme quand "requestfinished" ne se declenche jamais' do
      requete = instance_double(Puppeteer::HTTPRequest)
      reponse = instance_double(Puppeteer::HTTPResponse, request: requete)

      Thread.new do
        sleep 0.01
        page.emit_event('request', requete)
        sleep 0.01
        page.emit_event('response', reponse)
      end

      duree = Benchmark.realtime do
        generator.send(:attend_reseau_stabilise, page, idle_time: 20, timeout: 500, concurrency: 0)
      end

      expect(duree).to be < 0.5
    end

    it "n'attend jamais plus que le timeout si une requete ne se termine jamais" do
      requete = instance_double(Puppeteer::HTTPRequest)
      allow(Rails.logger).to receive(:warn)

      Thread.new do
        sleep 0.01
        page.emit_event('request', requete)
      end

      duree = Benchmark.realtime do
        generator.send(:attend_reseau_stabilise, page, idle_time: 20, timeout: 100, concurrency: 0)
      end

      expect(duree).to be < 0.5
      expect(Rails.logger).to have_received(:warn).with(/interrompue apres 100ms/)
    end

    it 'retire ses ecouteurs une fois termine' do
      generator.send(:attend_reseau_stabilise, page, idle_time: 10, timeout: 500)

      listeners = page.instance_variable_get(:@event_listeners)
      expect(listeners['request'].to_a).to be_empty
      expect(listeners['response'].to_a).to be_empty
      expect(listeners['requestfailed'].to_a).to be_empty
    end
  end
end
