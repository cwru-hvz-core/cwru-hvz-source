require 'spec_helper'

describe PeopleController do
  let(:person) { FactoryGirl.create(:person) }

  render_views

  describe '#edit' do
    subject { get :edit, id: person.id }

    it 'redirects to login when not loged in' do
      subject
      response.should redirect_to people_login_path
    end

    context 'when logged in' do
      before do
        log_in_as(person)
      end

      it 'allows you to edit your own info' do
        subject
        response.should be_success
      end

      context 'when editing someone else' do
        let(:other_person) { FactoryGirl.create(:person) }
        subject { get :edit, id: other_person.id }

        it "doesn't allow you to edit someone else" do
          subject
          response.should redirect_to root_url
        end

        context 'when you are an admin' do
          let(:person) { FactoryGirl.create(:admin) }

          it "allows you to edit someone else" do
            response.should be_success
          end
        end
      end
    end
  end

  describe '#update' do
    let(:new_phone)  { '1234567890' }
    let(:new_name )  { 'new name' }
    let(:params) do
      { id: person.id, person: { name: new_name, phone: new_phone } }
    end

    subject { post :update, params }

    context 'when unauthenticated' do
      it 'redirects to login' do
        subject
        response.should redirect_to people_login_path
      end
    end

    context 'when authenticated as a non-admin user' do
      before do
        log_in_as(person)
      end

      it 'allows you to update your name and phone number' do
        subject
        person.reload.name.should  == new_name
        person.reload.phone.should == new_phone
      end

      context "when you shouldn't be allowed to update your name" do
        before { Person.any_instance.stub(can_change_name?: false) }
        it "doesn't allow you to update your name" do
          subject
          person.reload.name.should_not == new_name
        end
      end

      it "doesn't allow you to make yourself an admin" do
        params[:person][:is_admin] = 'true'
        subject
        person.reload.is_admin.should be_false
      end

      context 'with another person' do
        let(:other_person) { FactoryGirl.create(:person) }

        it "doesn't allow you to modify them" do
          params[:id] = other_person.id
          expect { post :update, params }.
            to_not change { other_person.reload.name }
        end
      end
    end

    context 'as an admin user' do
      let(:admin) { FactoryGirl.create(:admin) }

      before do
        log_in_as(admin)
      end

      it 'allows you to edit other users' do
        subject
        person.reload.name.should == new_name
        person.reload.phone.should == new_phone
      end

      it 'allows you to make other users admins' do
        params[:person][:is_admin] = 'true'
        subject
        person.reload.is_admin.should be_true
      end
    end
  end
end
