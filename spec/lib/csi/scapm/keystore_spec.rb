# frozen_string_literal: true
require 'spec_helper'

describe CSI::SCAPM::Keystore do
  it 'scan method should exist' do
    scan_response = CSI::SCAPM::Keystore
    expect(scan_response).to respond_to :scan
  end

  it 'should display information for nist_800_53_requirements' do
    nist_800_53_requirements_response = CSI::SCAPM::Keystore
    expect(nist_800_53_requirements_response).to respond_to :nist_800_53_requirements
  end

  it 'should display information for authors' do
    authors_response = CSI::SCAPM::Keystore
    expect(authors_response).to respond_to :authors
  end

  it 'should display information for existing help method' do
    help_response = CSI::SCAPM::Keystore
    expect(help_response).to respond_to :help
  end
end
