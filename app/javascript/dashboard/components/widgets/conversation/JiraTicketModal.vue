<template>
  <woot-modal :show.sync="show" :on-close="onCancel">
    <div class="column content-box">
      <woot-modal-header
        :header-title="$t('EMAIL_TRANSCRIPT.TITLE')"
        :header-content="$t('EMAIL_TRANSCRIPT.DESC')"
      />
      <form @submit.prevent="onSubmit">
        <div class="medium-12 columns">
          <div>
            <label for="email">Email</label>
            <input v-model="email" @input="$v.email.$touch" id="email" class="input" type="email" placeholder="Email">
          </div>
          <div>
            <label for="message">Сообщение</label>
            <textarea v-model="message" @input="$v.message.$touch" id="message" class="input" type="text" placeholder="Сообщение" rows="4"></textarea>
          </div>
          <div>
            <label for="dialog_category">Категория диалога</label>
            <input v-model="dialog_category" @input="$v.dialog_category.$touch" id="dialog_category" class="input" type="text" placeholder="Категория диалога">
          </div>
          <div>
            <label for="agent">Проекты</label>
            <select v-model="selectedKey">
              <option v-for="proj in projects" :value="proj.key">
                {{ proj.name }}
              </option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <div class="medium-12 row">
            <woot-submit-button
              :button-text="$t('EMAIL_TRANSCRIPT.SUBMIT')"
              
            />
            <button class="button clear" @click.prevent="onCancel">
              {{ $t('EMAIL_TRANSCRIPT.CANCEL') }}
            </button>
          </div>
        </div>
      </form>
    </div>
  </woot-modal>
</template>

<script>
import { mapGetters } from 'vuex';
import { required, minLength, email } from 'vuelidate/lib/validators';
import alertMixin from 'shared/mixins/alertMixin';
export default {
  mixins: [alertMixin],
  props: {
    contact: {
      type: Object,
      default: () => ({}),
    },
    show: {
      type: Boolean,
      default: false,
    },
    
  },
  data() {
    return {
      selectedKey: null,
      isSubmitting: false,
      isLoading: true,
      email: "",
      username: "",
      browser: "",
      os: "",
      message: "",
      first_appeal: "",
      dialog_category: "",
      begin_link: "",
    };
  },
  validations: {
    email: {},
    message: {},
    dialog_category: {},
  },
  
  watch: {
    contact() {
      this.setTicketObject();
    },
  },
  mounted() {    
    this.isLoading = true;
    try {
      this.$store.dispatch('getProjects');
    } catch (error) {
      this.showAlert(this.$t('EMAIL_TRANSCRIPT.SEND_EMAIL_ERROR'));
    } finally {
      this.isLoading = false;
    }
  },
  computed: {
    ...mapGetters({
      projects: 'getProjects',
      jiraTicketResponse: 'getJiraTicketResponse',
      currentUser: 'getCurrentUser',
      currentChat: 'getSelectedChat',
      allConversations: 'getAllConversations',
    }),
    /*getFormData() {
      return {
        email: this.email,
        username: this.username,
        browser: this.browser,
        os: this.os,
        message: this.message,
        first_appeal: this.first_appeal,
        dialog_category: this.dialog_category,
        begin_link: this.begin_link,
      };
    }, */
    /*isFormValid() {
      if (this.selectedType) {
        if (this.sentToOtherEmailAddress) {
          return !!this.email && !this.$v.email.$error;
        }
        return true;
      }
      return false;
    },*/
  },
  methods: {
    onCancel() {
      this.$emit('cancel');
    },
    onSuccess() {
      this.$emit('success');
    },
    getMessages() {
      const [chat] = this.allConversations.filter(
        c => c.id === this.currentChat.id
      );
      return chat;
    },
    setTicketObject() {
      //const { email: email, phone_number: phoneNumber, name } = this.contact;
      //const additionalAttributes = this.contact.additional_attributes || {};
      debugger;
      this.username = username || '';
      this.email = email || '';
      this.browser = browser || '';
      this.os = os || '';
      this.message = message || '';
      this.first_appeal = first_appeal || '';
      this.dialog_category = dialog_category || '';
      this.begin_link = begin_link || '';
    },
    getTicketObject() {
      return {
        email: this.email,
        username: this.currentChat.meta.sender.name,
        browser: this.currentChat.additional_attributes.browser.browser_name,
        os: this.currentChat.additional_attributes.browser.platform_name,
        message: this.message,
        first_appeal: this.currentChat.additional_attributes.initiated_at.timestamp,
        dialog_category: this.dialog_category,
        begin_link: this.currentChat.additional_attributes.referer,
        projectKey: this.selectedKey,
        messages: this.getMessages(),
      };
    },
    async onSubmit() {
      this.$v.$touch();

      if (this.$v.$invalid) {
        return;
      }
      try {
        const saved = await this.$store.dispatch('sendJiraTicket', this.getTicketObject());
        this.onSuccess();
        this.showAlert("Тикет успешно отправлен в Jira!");
        // if (saved && jiraTicketResponse == 200) {
        //   debugger
        //   this.onSuccess();
        //   this.showAlert("Тикет успешно отправлен в Jira!");
        // }
      } catch (error) {
        this.showAlert("Произошла ошибка!");
      }
    },
  },
};
</script>
