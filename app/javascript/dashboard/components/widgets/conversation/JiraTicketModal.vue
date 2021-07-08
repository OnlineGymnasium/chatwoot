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
            <label for="username">Имя пользователя</label>
            <input v-model="username" @input="$v.username.$touch" id="username" class="input" type="text" placeholder="Имя пользователя">
          </div>
          <div>
            <label for="email">Email</label>
            <input v-model="email" @input="$v.email.$touch" id="email" class="input" type="email" placeholder="Email">
          </div>
          <div>
            <label for="browser">Браузер</label>
            <input v-model="browser" @input="$v.browser.$touch" id="browser" class="input" type="text" placeholder="Браузер">
          </div>
          <div>
            <label for="os">ОС</label>
            <input v-model="os" @input="$v.os.$touch" id="os" class="input" type="text" placeholder="ОС">
          </div>
          <div>
            <label for="message">Сообщение</label>
            <input v-model="message" @input="$v.message.$touch" id="message" class="input" type="text" placeholder="Сообщение">
          </div>
          <div>
            <label for="first_appeal">Время первого обращения</label>
            <input v-model="first_appeal" @input="$v.first_appeal.$touch" id="first_appeal" class="input" type="text" placeholder="Время первого обращения">
          </div>
          <div>
            <label for="dialog_category">Категория диалога</label>
            <input v-model="dialog_category" @input="$v.dialog_category.$touch" id="dialog_category" class="input" type="text" placeholder="Категория диалога">
          </div>
          <div>
            <label for="begin_link">Ссылка Начат из</label>
            <input v-model="begin_link" @input="$v.begin_link.$touch" id="begin_link" class="input" type="text" placeholder="Ссылка Начат из">
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
    username: {
      required,
      minLength: minLength(1),
    },
    email: {},
    browser: {},
    os: {},
    message: {},
    first_appeal: {},
    dialog_category: {},
    begin_link: {},
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
        username: this.username,
        browser: this.browser,
        os: this.os,
        message: this.message,
        first_appeal: this.first_appeal,
        dialog_category: this.dialog_category,
        begin_link: this.begin_link,
        projectKey: this.selectedKey,
      };
    },
    async onSubmit() {
      this.$v.$touch();

      if (this.$v.$invalid) {
        return;
      }
      try {
        const asd = await this.$store.dispatch('sendJiraTicket', this.getTicketObject());
        debugger
        if (asd && jiraTicketResponse.status == 200) {
          debugger
          this.onSuccess();
          this.showAlert("Тикет успешно отправлен в Jira!");
        }
      } catch (error) {
        this.showAlert("Произошла ошибка!");
      }
    },
  },
};
</script>
