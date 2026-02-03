class ContractsController < ApplicationController
  layout false

  def provider
    @contract = ContractSetting.current
    render "pages/contract_provider"
  end
end
