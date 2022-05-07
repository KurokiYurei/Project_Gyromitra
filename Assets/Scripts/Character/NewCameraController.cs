using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class NewCameraController : MonoBehaviour
{
    private PlayerInput playerInput;
    private InputAction moveCamera;

    [SerializeField]
    private PauseMenu m_pauseMenu;

    [SerializeField]
    private GameObject m_normalCamera;

    [SerializeField]
    private GameObject m_aimCamera;

    [SerializeField]
    private Transform m_player;

    [Header("Camera")]
    public float m_AimPitch = 0.0f;
    public float m_AimYaw = 0.0f;

    public float m_MinDistance = 2.0f;
    public float m_MaxDistance = 5.0f;

    public float m_YawRotationalSpeed = 360.0f;
    public float m_PitchRotationalSped = 180.0f;

    public float m_MinPitchDistance = 85.0f;
    public float m_MaxPitchDistance = 85.0f;

    public float m_MinAimPitchDistance = -30f;
    public float m_MaxAimPitchDistance = 30f;

    private float m_Pitch = 0.0f;

    public void SetIsAiming(bool l_isAiming)
    {
        if (l_isAiming)
        {
            m_normalCamera.SetActive(false);
            m_aimCamera.SetActive(true);
        }
        else
        {
            m_aimCamera.SetActive(false);
            m_normalCamera.SetActive(true);       
        }
    }

    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
        moveCamera = playerInput.actions["Look"];
    }

    void Update()
    {
        if (!m_pauseMenu.GetPaused())
        {
            Vector2 input = moveCamera.ReadValue<Vector2>();

            float l_MouseDeltaX = input.x;
            float l_MouseDeltaY = input.y;

            m_AimYaw += l_MouseDeltaX;
            m_Pitch -= l_MouseDeltaY;
            m_Pitch = Mathf.Clamp(m_Pitch, m_MinPitchDistance, m_MaxPitchDistance);

            //transform.eulerAngles = Vector3.Lerp(transform.eulerAngles, new Vector3(m_Pitch, m_AimYaw), 8 * Time.deltaTime);
            transform.rotation *= Quaternion.AngleAxis(l_MouseDeltaX, Vector3.up);
            transform.rotation *= Quaternion.AngleAxis(-l_MouseDeltaY, Vector3.right);

            var angles = transform.localEulerAngles;
            angles.z = 0;

            transform.localEulerAngles = angles;

            m_player.rotation = Quaternion.Euler(0, transform.rotation.eulerAngles.y, 0);


            Vector3 l_Forward = transform.forward;
            l_Forward.y = 0.0f;
            m_player.forward = l_Forward;

            transform.localEulerAngles = new Vector3(angles.x, 0, 0);
        }    
    }
}
