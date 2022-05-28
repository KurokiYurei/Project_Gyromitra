using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using static UnityEngine.InputSystem.InputAction;

public class CharacterControllerScript : MonoBehaviour, IRestartGameElement
{
    [SerializeField]
    private NewCameraController m_camController;

    [SerializeField]
    private Transform m_FollowRot;

    [Header("Stats")]

    [SerializeField]
    private float m_WalkSpeed = 1.5f;

    [SerializeField]
    private bool m_OnGround;

    [SerializeField]
    private float m_JumpSpeed = 7.7f;

    [SerializeField]
    private float m_jumpHorizontalSpeedDivider = 2f;

    [SerializeField]
    private float m_VerticalSpeed = 0.0f;

    [SerializeField]
    private float m_fallGravityMultiplier = 2f;

    [SerializeField]
    private float m_speedToFallDamage = 20f;

    [SerializeField]
    private float m_timeForBulletTime;

    private float m_onAirTimer;
    
    private bool m_jumped;

    private float m_bouncePower;

    private float m_initialBouncePower;

    private float m_bounceTimer;

    private float m_bounceDuration;
    
    private bool m_bouncing;
    
    private Vector3 m_bounceDirection;

    static PoolElements m_arrowPool;

    [SerializeField]
    private GameObject m_arrow;

    private CharacterHP m_player;

    [Header("Inputs")]
    private PlayerInput m_playerInput;
    private InputAction m_moveAction;
    private InputAction m_jumpAction;
    private InputAction m_AimAction;

    private CharacterController m_CharacterController;

    [SerializeField]
    private PauseMenu m_pauseMenu;

    [Header("On Mushrooms")]
    [SerializeField]
    private GameObject m_mushroomPrefab;
    [SerializeField]
    private GameObject m_mushroomWallPrefab;
    static DoublePoolElements m_mushroomPool;

    [SerializeField]
    private float m_mushroomBounceDuration;
    [SerializeField]
    private float m_mushroomBouncePower;
    [SerializeField]
    private float m_mushroomJumpSpeed = 10f;
    
    private bool m_jumpedOnMushroom;

    [Header("Bramble")]
    [SerializeField]
    private float m_brambleDamage;

    [SerializeField]
    private float m_bramblePushPower;

    [SerializeField]
    private float m_bramblePushDuration;

    [Header("Checkpoints")]
    [SerializeField]
    private Vector3 m_startPos;
    [SerializeField]
    private Quaternion m_startRot;
    [SerializeField]
    private CheckPoint m_currentCheckPoint;

    public delegate void OnBulletTimeDelegate(bool active);
    public OnBulletTimeDelegate OnBulletTime;

    public delegate void OnStopPoisonDelegate();
    public OnStopPoisonDelegate OnStopPoison;

    [Header("Occlusion Camera")]
    [SerializeField]
    private Camera m_occlusionCamera;
    [SerializeField]
    private float m_fovInArea;
    [SerializeField]
    private float m_fovOutArea;

    private void Awake()
    {
        Cursor.lockState = CursorLockMode.Locked;
        m_CharacterController = GetComponent<CharacterController>();
        m_playerInput = GetComponent<PlayerInput>();
        m_moveAction = m_playerInput.actions["Movement"];
        m_jumpAction = m_playerInput.actions["Jump"];
        m_AimAction = m_playerInput.actions["Aim"];

        m_player = GetComponent<CharacterHP>();

        m_mushroomPool = new DoublePoolElements(5, transform, m_mushroomPrefab, m_mushroomWallPrefab);
        m_arrowPool = new PoolElements(5, null, m_arrow);

        m_fovInArea = 80f;
        m_fovOutArea = 40f;
    }
    void Start()
    {
        m_startPos = transform.position;
        m_startRot = transform.rotation;

        GameManagerScript.m_instance.AddRestartGameElement(this);
    }

    void Update()
    {
        Jump();

        //Aim
        if (!m_pauseMenu.GetPaused())
        {
            if (m_AimAction.triggered)
            {
                m_camController.SetIsAiming(true);
                if (m_onAirTimer > m_timeForBulletTime)
                    OnBulletTime?.Invoke(true);
            }
            if (m_AimAction.WasReleasedThisFrame())
            {
                m_camController.SetIsAiming(false);
                OnBulletTime?.Invoke(false);
            }
        }
    }
    void FixedUpdate()
    {
        //Movement function
        Movement();
    }

    /// <summary>
    /// movement 
    /// </summary>
    private void Movement()
    {
        Vector2 input = m_moveAction.ReadValue<Vector2>();

        Vector3 l_Forward = m_FollowRot.transform.forward;
        Vector3 l_Right = m_FollowRot.transform.right;
        l_Forward.y = 0.0f;
        l_Right.y = 0.0f;

        l_Forward.Normalize();
        l_Right.Normalize();

        Vector3 l_Movement = Vector3.zero;

        if (!m_bouncing)
        {
            l_Movement = l_Right * input.x;
            l_Movement += l_Forward * input.y;

            float l_Speed = m_WalkSpeed;

            if (m_jumped)
            {
                l_Speed /= m_jumpHorizontalSpeedDivider;
            }

            l_Movement.Normalize();
            l_Movement *= l_Speed * Time.deltaTime;
        }
        else
        {
            l_Movement = -m_bounceDirection * m_bouncePower * Time.deltaTime;
            m_bouncePower = Mathf.MoveTowards(m_bouncePower, 0, (m_initialBouncePower / m_bounceDuration) * Time.deltaTime);
            m_bounceTimer += Time.deltaTime;
            if (m_bounceTimer >= m_bounceDuration)
            {
                m_bouncing = false;
            }
        }

        //Gravity
        
        if (m_VerticalSpeed < 0f)
        {
            m_VerticalSpeed += Physics.gravity.y * Time.deltaTime * m_fallGravityMultiplier;
        }
        else
        {
            m_VerticalSpeed += Physics.gravity.y * Time.deltaTime;
            m_jumpedOnMushroom = false;
        }

        l_Movement.y = m_VerticalSpeed * Time.deltaTime;

        CollisionFlags l_CollisionFlags = m_CharacterController.Move(l_Movement);

        if ((l_CollisionFlags & CollisionFlags.Below) != 0 && !m_jumpedOnMushroom)
        {
            FallDamage();
            m_OnGround = true;
            m_VerticalSpeed = 0.0f;
            m_onAirTimer = 0f;
            m_jumped = false;

        }
        else
        {
            m_OnGround = false;
            m_onAirTimer += Time.deltaTime;
        }

        if ((l_CollisionFlags & CollisionFlags.Above) != 0 && m_VerticalSpeed > 0.0f)
        {
            m_VerticalSpeed = 0.0f;
        }

        if (m_onAirTimer > 1f)
        {
            m_jumped = true;
        }
    }

    /// <summary>
    /// jump
    /// </summary>
    private void Jump()
    {
        if (m_jumpAction.triggered && (m_OnGround || m_onAirTimer < 0.3f) && !m_jumped)
        {
            m_VerticalSpeed = m_JumpSpeed;
            m_OnGround = false;
            m_jumped = true;
        }
    }

    /// <summary>
    /// restart hp / position / forward of the player when {all the genders you can think} is bad and dies
    /// </summary>
    public void RestartGame()
    {
        OnStopPoison?.Invoke();

        m_CharacterController.enabled = false;
        if (m_currentCheckPoint != null)
        {
            transform.position = m_currentCheckPoint.m_startPosition.position;
            transform.rotation = m_currentCheckPoint.m_startPosition.rotation;
        }
        else
        {
            transform.position = m_startPos;
            transform.rotation = m_startRot;
        }
        m_player.ResetHP();
        m_CharacterController.enabled = true;
    }

    /// <summary>
    /// setter
    /// </summary>
    /// <param name="newSpeed"></param>
    public void SetVerticalSpeed(float newSpeed)
    {
        m_VerticalSpeed = newSpeed;
    }

    /// <summary>
    /// getter of the vertical speed
    /// </summary>
    /// <returns></returns>
    public float GetVerticalSpeed()
    {
        return m_VerticalSpeed;
    }

    public void OnControllerColliderHit(ControllerColliderHit hit)
    {
        if (hit.collider.tag == "Mushroom")
        {
            if (hit.normal.y < 0.5f)
            {
                SetBounceParameters(hit.transform.position - transform.position, m_mushroomBouncePower, m_mushroomBounceDuration);
            }
            else
            {
                m_jumpedOnMushroom = true;
                SetVerticalSpeed(m_mushroomJumpSpeed);
                m_jumped = true;
            }
        }

        if (hit.collider.tag == "Bramble")
        {
            m_player.Damage(m_brambleDamage);
            SetBounceParameters(hit.transform.position - transform.position, m_bramblePushPower, m_bramblePushDuration);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(UtilsGyromitra.SearchForTag("CheckPoint")))
        {
            m_currentCheckPoint = other.GetComponent<CheckPoint>();
        }

        if (other.CompareTag(UtilsGyromitra.SearchForTag("ChangeOcclusion")))
        {
            m_occlusionCamera.fieldOfView = m_fovInArea;
        }

    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag(UtilsGyromitra.SearchForTag("ChangeOcclusion")))
        {
            m_occlusionCamera.fieldOfView = m_fovOutArea;
        }
    }

    /// <summary>
    /// set the bounce parameters for the player
    /// </summary>
    /// <param name="dir"></param>
    /// <param name="power"></param>
    /// <param name="duration"></param>
    public void SetBounceParameters(Vector3 dir, float power, float duration)
    {
        m_bounceDirection = dir;
        m_bounceDirection.Normalize();
        m_bounceTimer = 0;
        if (m_OnGround)
        {
            m_bouncePower = power * 2;
            m_initialBouncePower = power * 2;
            m_bounceDuration = duration;
        }
        else
        {
            m_bouncePower = power;
            m_initialBouncePower = power;
            m_bounceDuration = duration * 2;
        }
        m_bouncing = true;
    }

    /// <summary>
    /// return the pool arrow pool
    /// </summary>
    /// <returns></returns>
    public static PoolElements GetArrowPool()
    {
        return m_arrowPool;
    }

    /// <summary>
    /// return the mushrooms pool
    /// </summary>
    /// <returns></returns>
    public static DoublePoolElements GetMushroomPool()
    {
        return m_mushroomPool;
    }

    /// <summary>
    /// deal damage to the player when it falls to the groud
    /// </summary>
    private void FallDamage()
    {
        if (m_VerticalSpeed <= -m_speedToFallDamage)
        {
            //yield return new WaitForSeconds(3);
            m_player.Damage(10 - ((m_VerticalSpeed + m_speedToFallDamage) * 2));
            print(10 - ((m_VerticalSpeed + m_speedToFallDamage) * 2));
        }
    }
}