require "rails_helper"

RSpec.describe "/followups", type: :request do
  let(:admin) { create(:casa_admin) }
  let(:contact) { create(:case_contact) }

  describe "PATCH /resolve" do
    context "followup exists" do
      let!(:followup) { create(:followup, case_contact: contact) }

      it "marks it as :resolved" do
        sign_in admin
        patch resolve_followup_path(followup)

        expect(followup.reload.resolved?).to be_truthy
      end
    end

    context "followup doesn't exists" do
      it "raises ActiveRecord::RecordNotFound" do
        sign_in admin

        expect {
          patch resolve_followup_path(444444)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      context "no followup exists yet" do
        it "creates a followup" do
          sign_in admin

          expect {
            post case_contact_followups_path(contact)
          }.to change(Followup, :count).by(1)
        end
      end

      context "followup exists and is in :requested status" do
        let!(:followup) { create(:followup, case_contact: contact) }

        it "should not create another followup" do
          sign_in admin

          expect {
            post case_contact_followups_path(contact)
          }.not_to change(Followup, :count)
        end
      end
    end

    context "with invalid case_contact" do
      it "raises ActiveRecord::RecordNotFound" do
        sign_in admin

        expect {
          post case_contact_followups_path(444444)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
