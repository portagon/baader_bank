# frozen_string_literal: true

RSpec.describe BaaderBank::Client::PomsOrders do
  subject(:client) { BaaderBank::Client.new(BaaderBank.configuration) }

  before { stub_login }

  it "#poms_orders gets the securities-account-scoped poms-orders endpoint" do
    stub = stub_api(:get, "securities-accounts/555/poms-orders")
    client.poms_orders(555)
    expect(stub).to have_been_requested
  end
end
