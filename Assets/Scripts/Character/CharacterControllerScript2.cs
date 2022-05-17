using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using static UnityEngine.InputSystem.InputAction;

public class CharacterControllerScript2 : MonoBehaviour, IRestartGameElement
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

    public GameManagerScript m_gameManager;

    [SerializeField]
    private float m_fallDamage = 10.0f;

    [Header("Inputs")]
    private PlayerInput m_playerInput;
    private InputAction m_moveAction;
    private InputAction m_jumpAction;
    private InputAction m_AimAction;

    [SerializeField]
    private Rigidbody m_rigidbody;

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

    private void Awake()
    {
        Cursor.lockState = CursorLockMode.Locked;
        m_rigidbody = GetComponent<Rigidbody>();
        m_playerInput = GetComponent<PlayerInput>();
        m_moveAction = m_playerInput.actions["Movement"];
        m_jumpAction = m_playerInput.actions["Jump"];
        m_AimAction = m_playerInput.actions["Aim"];

        m_player = GetComponent<CharacterHP>();

        m_mushroomPool = new DoublePoolElements(5, transform, m_mushroomPrefab, m_mushroomWallPrefab);
        m_arrowPool = new PoolElements(5, null, m_arrow);
    }
    void Start()
    {
        m_startPos = transform.position;
        m_startRot = transform.rotation;
        m_gameManager.AddRestartGameElement(this);
    }

    void Update()
    {
        //Movement function
        Movement();

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
        l_Movement = l_Right * input.x;
        l_Movement += l_Forward * input.y;

        Vector3 l_PlayerMovementInput = new Vector3(l_Movement.x, 0f, l_Movement.z);
        Vector3 l_MoveVector = transform.TransformDirection(l_PlayerMovementInput) * m_WalkSpeed * Time.deltaTime;

        m_rigidbody.velocity = new Vector3(l_MoveVector.x, m_rigidbody.velocity.y, l_MoveVector.z);

        print(l_Movement);
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
            Debug.DrawRay(hit.point, hit.normal, Color.red, 2f);
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
        if (m_VerticalSpeed <= -15)
        {
            //yield return new WaitForSeconds(3);
            m_player.Damage(m_fallDamage);
        }
    }
}