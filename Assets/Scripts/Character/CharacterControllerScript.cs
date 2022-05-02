using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using static UnityEngine.InputSystem.InputAction;

public class CharacterControllerScript : MonoBehaviour, IRestartGameElement
{
    [SerializeField]
    private Camera m_Camera;

    [Header("Stats")]

    [SerializeField]
    private float m_WalkSpeed = 1.5f;

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
    private float smoothInputSpeed = 0.1f;

    private float m_onAirTimer;
    
    private bool m_jumped;

    private float m_bouncePower;
    
    private float m_bounceTimer;
    
    private bool m_bouncing;
    
    private Vector3 m_bounceDirection;

    static PoolElements m_arrowPool;

    [SerializeField]
    private GameObject m_arrow;

    private CharacterHP m_player;

    public GameManagerScript m_gameManager;

    [SerializeField]
    private float m_fallDamage = 10.0f;

    [Range(0.0f, 1.0f)]
    [SerializeField]
    private float m_LerpRotationPct = 0.9f;

    [Header("Inputs")]
    private PlayerInput m_playerInput;
    private InputAction m_moveAction;
    private InputAction m_jumpAction;
    private InputAction m_AimAction;

    private CharacterController m_CharacterController;
    private CameraController m_CameraController;

    [Header("Camera")]
    [SerializeField]
    private Transform m_ShoulderCameraPosition;
    [SerializeField]
    private Transform m_Bow;

    [Header("On Mushrooms")]
    [SerializeField]
    private GameObject m_mushroomPrefab;
    [SerializeField]
    private GameObject m_mushroomWallPrefab;
    static DoublePoolElements m_mushroomPool;

    [SerializeField]
    private int m_maxMushrooms;
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


    private void Awake()
    {
        m_CharacterController = GetComponent<CharacterController>();
        m_CameraController = m_Camera.GetComponent<CameraController>();
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

        RotWithCam();

        //Aim
        if (m_AimAction.triggered)
        {
            if (m_ShoulderCameraPosition.eulerAngles.x < 360 + m_CameraController.m_MinAimPitchDistance && m_ShoulderCameraPosition.eulerAngles.x > 180)
                m_CameraController.m_AimPitch = m_CameraController.m_MinAimPitchDistance;
            else if (m_ShoulderCameraPosition.eulerAngles.x >= 360 + m_CameraController.m_MinAimPitchDistance)
                m_CameraController.m_AimPitch = m_ShoulderCameraPosition.eulerAngles.x - 360;
            else
                m_CameraController.m_AimPitch = m_ShoulderCameraPosition.eulerAngles.x;

            m_CameraController.SetIsAiming(true);
        }
        if (m_AimAction.WasReleasedThisFrame())
        {
            m_CameraController.SetIsAiming(false);
        }
    }

    /// <summary>
    /// Rotate the camera with the mouse movement
    /// </summary>
    private void RotWithCam()
    {
        Vector3 l_Forward = m_Camera.transform.forward;
        l_Forward.y = 0.0f;
        transform.forward = l_Forward;

        Vector3 l_bowRot = m_Camera.transform.eulerAngles;
        m_Bow.eulerAngles = l_bowRot;
    }

    /// <summary>
    /// movement 
    /// </summary>
    private void Movement()
    {
        Vector2 input = m_moveAction.ReadValue<Vector2>();

        Vector3 l_Forward = m_Camera.transform.forward;
        Vector3 l_Right = m_Camera.transform.right;
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

            Jump();
        }
        else
        {
            l_Movement = -m_bounceDirection * m_bouncePower * Time.deltaTime;
            m_bounceTimer -= Time.deltaTime;
            if (m_bounceTimer < 0)
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
        if (m_jumpAction.triggered && (m_OnGround || m_onAirTimer < 0.3f))
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
            Debug.DrawRay(hit.point, hit.normal, Color.red, 2f);
            if (hit.normal.y < 0.5f)
            {
                Debug.Log("A REBOTAR");
                SetBounceParameters(hit.transform.position - transform.position, m_mushroomBouncePower, m_mushroomBounceDuration);
            }
            else
            {
                m_jumpedOnMushroom = true;
                Debug.Log("A SALTAR");
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
        if (other.CompareTag("CheckPoint"))
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
        m_bouncePower = power;
        m_bounceTimer = duration;
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
    public static DoublePoolElements GetMushroomPool()
    {
        return m_mushroomPool;
    }
    private void FallDamage()
    {
        if (m_VerticalSpeed <= -15)
        {
            //yield return new WaitForSeconds(3);
            print("damage");
            m_player.Damage(m_fallDamage);
        }
    }
}






/*

In CONGRESS, July 4, 2021
The unanimous Declaration of the eight united Crewmates of Among Us
When in the Course of ?mogusa game of Among Us ????, it becomes necessary for one crew to dissolve the sussy bands which have connected them with another, and to assume among the powerussys ???? of the shipussy, the separate and equal station to which the Laws of Nature entitle them, a decent respect to the opinions of gamers requires that they should mald about the causes which impel them to the ejection of the sus.
We hold these truths to be the opposite of sus, that all Crewmates are created equal, that they are endowed by Innersloth with certain unalienable Conditions, that Among? Us are Impostors, Crewmates and the completion of Tasks.” — That to secure the victory of the Crewmates, Emergency Meetings are instituted Among Us, deriving their just powers from the consent of the Crewmates, —That whenever any Form of Sussiness ?????? becomes destructive of these ends, it is the Right of the Crewmates to eject it, and to institute new Emergency Meetings, laying its foundation on such principles and organizing its powers in such form, as to them shall seem most likely to effect their Survival. Logical deduction, indeed, will dictate that Impostors should not be ?Among Us for light and transient causes; and accordingly all experience hath shewn, that Crewmates are more disposed to suffer, while ejections are sufferable, than to right themselves by abolishing the forms to which they are accustomed. But when a long train of failed tasks, pursuing invariably the same Impostor Win evinces a design to kill ?????? all the Crewmates, it is their right, it is their duty, to eject the impostors and to provide new Guards ? for their future security.
Such has been the patient sufferance of these Crewmates; and such is now the necessity which constrains them to hold an Emergency Meeting. The history of the present ?? Accused ?? Crewmate is a history of repeated failed tasks, all having in direct object the establishment of ??? death!!! violence!!!! piles of bodies!!! <333333 :DDDDDDDD ???. To prove this, let Facts be submitted to ???? Discord Voice Chat.
He has refused his card swipe, the most wholesome and necessary for the public good.
He has forbidden his ?????????? Crewmates to clean the O2 filter, because he said “i am trash like these leaves are i kin them you cant take them away”, and has utterly neglected to attend to them.
He has called together Emergency Meetings at times unusual, uncomfortable and distant from the depository of their Public Records, for the sole purpose of fatiguing them into compliance ???????????? >.<what ?? are ?? you doing stepbro ?? HELLO?? with his measures ??.
He has remained stationary at the asteroids station for two (2) minutes, yet the gun ?? on the outer part of the ship has not fired ?? ???? a single time.
He ?? has refused to Empty Chute, preferring to let the spaceship rot in FILTH and COCKROACHES, to reflect his current standard of living (SOL - From Investopedia: Standard of living refers to the quantity and quality of material goods and services available to a given population.) in the real world. Because hes a neet like you (the reader) are
He has kept Among Us, in times of peace, Assorted Weaponry without the Consent of his Crewmates.
For quartering large bodies of Crewmates Among Us:
For ???? ejecting them, by a mock Trial from punishment for any Murders which they should commit on the Crewmates of this spaceship:
For depriving us in many cases, of the benefit of Trial by Crewmate.
He is at this time murdering Blue ?? Crewmate (may he rest in peace inshallah ?????? grapeee ??????????????) , as observed by Green Crewmate, to compleat the works of death, desolation and tyranny, already begun with circumstances of Cruelty & Perfidy scarcely paralleled in the most barbarous ages, and totally unworthy the Head of a civilized spaceship.
He has constrained our fellow Crewmates to bear Arms against one another, to become the executioners of their friends and Brethren, or to fall themselves by venting ( announcement: please put vents in #vent idc about your emotional crises)?? while the CCTV ?? was on.
In every stage of these Oppressions We have Petitioned for Redress in the most humble terms: Our repeated Emergency Meetings have been answered only by repeated injury. A Crewmate, whose character is thus marked by every act which may define an Impostor, is unfit to be a member of a Spaceship of Crewmates.
??? Nor have We been wanting in attentions to our Crewmate brethren. We have warned them from time to time of attempts by their Crewmate lookalikes to stab the shit out of us. We have reminded them of the circumstances of our emigration and settlement here. We have appealed to their native justice and magnanimity, and we have conjured them by the ties of our common kindred to disavow these usurpations, which, would inevitably interrupt our connections and correspondence. They too have been deaf to the voice of justice and of consanguinity.
We must, therefore, acquiesce in the necessity, which denounces our Separation via Ejection ????, and hold them, as we hold the rest of Crewmatekind, Sussies in War, in Peace Friends.
"We, therefore, the Representatives of the Spaceship, in Emergency Meetings, Assembled, appealing to the Electorate for the rectitude of our intentions, do, in the Name, and by Authority of the good People of this Spaceship ??, solemnly publish and declare, That these Crewmates are, and of Right ought to let this Impostor Boil In Space; that they are Absolved from all Allegiance to the Impostor, and that all sus ?????? connection between them and this Crewmate, is and ought to be totally dissolved; and that as Ejected Crewmates, they have no Power to levy War, conclude Peace, contract Alliances, establish Commerce, and to do all other Acts and Things which Independent Crewmates may of right do. And for the support of this Declaration, with a firm reliance on the protection of divine Innersloth, we mutually pledge to each other our Lives, our Fortunes and our Sacred Honour." ????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????
??????????????????????????????


*/