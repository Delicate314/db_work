<template>
  <div class="login">

    <el-form ref="loginForm" :model="loginForm" :rules="rules">

      <div class="login-pad">
        <div class="title">
          新能源汽车销售管理系统
        </div>

        <!-- 入口选择 -->
        <div class="login-type-selector">
          <el-radio-group v-model="loginForm.loginType" @change="handleLoginTypeChange">
            <el-radio-button label="user">用户端</el-radio-button>
            <el-radio-button label="admin">管理员端</el-radio-button>
          </el-radio-group>
        </div>

        <div class="login-context">

          <el-form-item class="username-pad" prop="loginName">
            <el-input class="username-input" placeholder="请输入用户名" v-model="loginForm.loginName"
              prefix-icon="el-icon-user-solid" type="text" autocomplete="off">
            </el-input>
          </el-form-item>

          <el-form-item class="password-pad" prop="password">
            <el-input class="password-input" placeholder="请输入密码" v-model="loginForm.password" prefix-icon="el-icon-lock"
              type="password" autocomplete="off">
            </el-input>
          </el-form-item>

          <el-form-item class="verifycode-pad" prop="inputcode">
            <el-input class="verifycode-input" placeholder="请输入验证码" v-model="loginForm.inputcode"
              prefix-icon="el-icon-key" autocomplete="off" type="text">
            </el-input>
            <div class="login-code-container" @click="refreshCode">
              <!--验证码组件-->
              <dentify :identifyCode="identifyCode"></dentify>
            </div>
          </el-form-item>

          <a v-if="loginForm.waiting">
            <el-button class="login-button" type="primary" @click="login" icon="el-icon-loading">
              登录中...
            </el-button>
          </a>
          <a v-else>
            <el-button class="login-button" type="primary" @click="login">
              登录
            </el-button>
          </a>

        </div>
      </div>

    </el-form>
  </div>
</template>

<script>
import dentify from '../../components/dentify'
import user from '../../store/modules/user'
import { userLogin } from '../../api/user'
import { _saveLocalStorage, _clearStorage } from '../../tools/utils'

export default {
  components: {
    dentify
  },
  data: function () {
    return {
      init: _clearStorage(),
      loginForm: {
        loginName: '',
        password: '',
        waiting: false,
        inputcode: '',
        loginType: 'user' // 默认用户端，可选：'user' 或 'admin'
      },
      identifyCodes: '1234567890abcdefjhijklinpoqrsduvwxyz', // 随机串内容,从这里随机抽几个显示验证码
      identifyCode: '',
      rules: {
        loginName: [
          { required: true, message: '用户名不得为空', trigger: 'blur' }
        ],
        password: [
          { required: true, message: '密码不得为空', trigger: 'blur' }
        ],
        inputcode: [
          { required: true, message: '请输入验证码', trigger: 'blur' }
        ]
      }
    }
  },
  methods: {
    storeUserInfo(res) {
      _saveLocalStorage('id', res.data.id)
      _saveLocalStorage('name', res.data.name)
      _saveLocalStorage('type', res.data.role.id)
      user.state.id = res.data.id
      user.state.loginName = res.data.name
      user.state.type = res.data.role.id
    },
    handleLoginTypeChange() {
      // 切换入口时清空表单
      this.loginForm.loginName = ''
      this.loginForm.password = ''
      this.loginForm.inputcode = ''
      this.refreshCode()
    },
    login() {
      if (this.loginForm.loginName === '' || this.loginForm.password === '' || this.loginForm.inputcode === '') {
        this.$message.error('请填写完整用户名、密码和验证码')
        this.refreshCode()
      } else {
        if (this.loginForm.inputcode === this.identifyCode) {
          this.loginForm.waiting = true

          // 只发送后端需要的字段：loginName 和 password
          const loginData = {
            loginName: this.loginForm.loginName,
            password: this.loginForm.password
          }

          userLogin(loginData).then(res => {
            if (res.data !== null) {
              // 验证角色是否匹配选择的入口
              const userRoleId = res.data.role.id
              const isAdmin = userRoleId === 2 // 角色ID 2 是中心管理员

              if (this.loginForm.loginType === 'admin' && !isAdmin) {
                this.loginForm.waiting = false
                this.$message.error('该账号不是管理员，请从用户端登录')
                this.refreshCode()
                return
              }

              if (this.loginForm.loginType === 'user' && isAdmin) {
                this.loginForm.waiting = false
                this.$message.error('管理员账号请从管理员端登录')
                this.refreshCode()
                return
              }

              this.storeUserInfo(res)
              this.$message.success('登陆成功')
              this.$router.push({ path: '/main' })
            } else {
              this.loginForm.waiting = false
              this.$message.error('用户名或密码错误')
              this.refreshCode()
            }
          }).catch(err => {
            this.loginForm.waiting = false
            this.$message.error('登录失败，请稍后重试')
            this.refreshCode()
          })
        } else {
          this.$message.error('验证码错误')
          this.refreshCode()
        }
      }
    },
    refreshCode() {
      this.identifyCode = ''
      this.makeCode(this.identifyCodes, 4)
    },
    // 获取验证码的值
    makeCode(o, l) {
      for (let i = 0; i < l; i++) {
        // 通过循环获取字符串内随机几位
        this.identifyCode +=
          this.identifyCodes[this.randomNum(0, this.identifyCodes.length)]
      }
    },
    // 随机数字：用于当角标拿字符串的值
    randomNum(min, max) {
      return Math.floor(Math.random() * (max - min) + min)
    }
  },
  mounted() {
    this.identifyCode = ''
    this.makeCode(this.identifyCodes, 4)
  }

}
</script>

<style>
.login {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  width: 100%;
  top: 0;
  left: 0;
  zoom: 1;
  position: absolute;
  background-repeat: no-repeat;
  background-attachment: fixed;
  background-image: url("../../assets/images/login-background.jpg");
  background-size: cover;
  background-position: center;
}

.title {
  margin-top: 5%;
  text-align: center;
  color: #707070;
  font-size: 25px;
  margin-bottom: 10%;
}

.login-pad {
  border-radius: 6px;
  background: #ffffff;
  width: 400px;
  padding: 25px 25px 5px 25px;
  height: 460px;
  box-shadow: 5px 5px 5px 5px rgba(0, 0, 0, 0.5);
}

.login-type-selector {
  margin-bottom: 20px;
  display: flex;
  justify-content: center;
}

.verifycode-input {
  width: 60%;
  float: left;
  margin-right: 10%;
}

.login-button {
  margin-top: 40px;
  float: bottom;
  width: 100%;
}

.login-code-container {
  height: 40px;
}
</style>
